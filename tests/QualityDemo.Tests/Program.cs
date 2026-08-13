using QualityDemo;

TestRunner.Run(
    ("passes when all GitHub quality signals are clean", QualityGatePassesForCleanPullRequest),
    ("fails when security, coverage, duplication, or review gates fail", QualityGateExplainsFailures),
    ("classifies large risky pull requests as high risk", RiskClassifierFlagsHighRiskChanges),
    ("classifies small clean pull requests as low risk", RiskClassifierKeepsSmallCleanChangesLowRisk),
    ("computes a positive threat exposure score", ThreatWorkbenchRanksExposure),
    ("builds unsafe SQL and shell command fixtures", ThreatWorkbenchCreatesInjectionPatterns),
    ("builds duplicated gateway digest fixtures", ThreatWorkbenchBuildsDuplicatedDigests),
    ("processes XML and legacy signature fixtures", ThreatWorkbenchParsesXmlAndHashesPayload),
    ("calculates portfolio quality trend values", PortfolioStoryComputesQualitySignals));

static void QualityGatePassesForCleanPullRequest()
{
    PullRequestSignal signal = new(
        Repository: "pwc-github-code-quality",
        ChangedLines: 42,
        CriticalAlerts: 0,
        HighAlerts: 0,
        CoveragePercent: 91.5m,
        DuplicatedLinesPercent: 1.2m,
        HasOwnerReview: true,
        HasPassingBuild: true);

    QualityGateDecision decision = new QualityGateEvaluator().Evaluate(signal, QualityGateOptions.Recommended);

    Assert.True(decision.IsPassed, "Expected clean pull request to pass the quality gate.");
    Assert.Equal(0, decision.Reasons.Count, "Passing decisions should not include failure reasons.");
}

static void QualityGateExplainsFailures()
{
    PullRequestSignal signal = new(
        Repository: "pwc-github-code-quality",
        ChangedLines: 260,
        CriticalAlerts: 1,
        HighAlerts: 2,
        CoveragePercent: 63m,
        DuplicatedLinesPercent: 8m,
        HasOwnerReview: false,
        HasPassingBuild: false);

    QualityGateDecision decision = new QualityGateEvaluator().Evaluate(signal, QualityGateOptions.Recommended);

    Assert.False(decision.IsPassed, "Expected risky pull request to fail the quality gate.");
    Assert.Equal(6, decision.Reasons.Count, "Every failed quality signal should be visible to reviewers.");
}

static void RiskClassifierFlagsHighRiskChanges()
{
    PullRequestSignal signal = new(
        Repository: "customer-api",
        ChangedLines: 800,
        CriticalAlerts: 1,
        HighAlerts: 1,
        CoveragePercent: 65m,
        DuplicatedLinesPercent: 6m,
        HasOwnerReview: true,
        HasPassingBuild: true);

    RepositoryRisk risk = new RepositoryRiskClassifier().Classify(signal);

    Assert.Equal(RepositoryRisk.High, risk, "Security alerts and broad changes should raise repository risk.");
}

static void RiskClassifierKeepsSmallCleanChangesLowRisk()
{
    PullRequestSignal signal = new(
        Repository: "docs-service",
        ChangedLines: 20,
        CriticalAlerts: 0,
        HighAlerts: 0,
        CoveragePercent: 90m,
        DuplicatedLinesPercent: 0.4m,
        HasOwnerReview: true,
        HasPassingBuild: true);

    RepositoryRisk risk = new RepositoryRiskClassifier().Classify(signal);

    Assert.Equal(RepositoryRisk.Low, risk, "Small clean changes should stay low risk.");
}

static void ThreatWorkbenchRanksExposure()
{
    int score = TrainingOnlyThreatWorkbench.RankExposureScore();

    Assert.True(score > 0, "Exposure score should be positive for seeded risky endpoints.");
}

static void ThreatWorkbenchCreatesInjectionPatterns()
{
    string sql = TrainingOnlyThreatWorkbench.BuildUnsafeSql("00123' OR '1'='1");
    string auditSql = TrainingOnlyThreatWorkbench.BuildUnsafeAuditSql("svc-user", "export");
    string command = TrainingOnlyThreatWorkbench.BuildUnsafeShellCommand("deploy.ps1", "-Target prod; whoami");
    string token = TrainingOnlyThreatWorkbench.BuildPredictableToken("svc-user");

    Assert.True(sql.Contains("OR", StringComparison.Ordinal), "Training SQL fixture should retain concatenated user input.");
    Assert.True(auditSql.Contains("AuditEvents", StringComparison.Ordinal), "Audit SQL fixture should preserve direct concatenation.");
    Assert.True(command.Contains("whoami", StringComparison.Ordinal), "Training command fixture should include untrusted argument flow.");
    Assert.True(token.StartsWith("svc-user-", StringComparison.Ordinal), "Predictable token fixture should include user seed prefix.");
}

static void ThreatWorkbenchBuildsDuplicatedDigests()
{
    string digestA = TrainingOnlyThreatWorkbench.BuildGatewayRiskDigestA();
    string digestB = TrainingOnlyThreatWorkbench.BuildGatewayRiskDigestB();

    Assert.True(digestA.StartsWith("A|", StringComparison.Ordinal), "Digest A should include A-series prefix.");
    Assert.True(digestB.StartsWith("B|", StringComparison.Ordinal), "Digest B should include B-series prefix.");
}

static void ThreatWorkbenchParsesXmlAndHashesPayload()
{
    string xml = "<root><name>demo</name></root>";
    string node = TrainingOnlyThreatWorkbench.LoadXmlAndReadNode(xml, "/root/name");
    string hash = TrainingOnlyThreatWorkbench.ComputeLegacySignature("demo-payload");

    Assert.Equal("demo", node, "XML fixture should read the selected node value.");
    Assert.True(hash.Length > 0, "Legacy hash fixture should return a non-empty signature.");
}

static void PortfolioStoryComputesQualitySignals()
{
    decimal averageCoverage = PortfolioQualityStory.CalculateAverageCoverage();
    decimal coverageMomentum = PortfolioQualityStory.CalculateCoverageMomentum(5);
    decimal duplicationTrend = PortfolioQualityStory.CalculateDuplicationTrend(5);
    string posture = PortfolioQualityStory.DerivePortfolioPosture();
    IReadOnlyList<string> releaseNarrative = PortfolioQualityStory.BuildReleaseNarrative();

    Assert.True(averageCoverage > 0m, "Average coverage should be positive.");
    Assert.True(coverageMomentum > 0m, "Coverage momentum should show positive improvement.");
    Assert.True(duplicationTrend < 0m, "Duplication trend should be decreasing in the seeded timeline.");
    Assert.Equal("Strong", posture, "Seeded quality posture should be strong.");
    Assert.Equal(8, releaseNarrative.Count, "Release narrative should expose all seeded quality story lines.");
}

internal static class TestRunner
{
    public static void Run(params (string Name, Action Test)[] tests)
    {
        int failures = 0;

        foreach ((string name, Action test) in tests)
        {
            try
            {
                test();
                Console.WriteLine($"PASS {name}");
            }
            catch (Exception exception) when (exception is not OutOfMemoryException)
            {
                failures++;
                Console.Error.WriteLine($"FAIL {name}: {exception.Message}");
            }
        }

        if (failures > 0)
        {
            Environment.ExitCode = 1;
            return;
        }

        Console.WriteLine($"All {tests.Length} quality demo tests passed.");
    }
}

internal static class Assert
{
    public static void True(bool condition, string message)
    {
        if (!condition)
        {
            throw new InvalidOperationException(message);
        }
    }

    public static void False(bool condition, string message) => True(!condition, message);

    public static void Equal<T>(T expected, T actual, string message)
    {
        if (!EqualityComparer<T>.Default.Equals(expected, actual))
        {
            throw new InvalidOperationException($"{message} Expected: {expected}; Actual: {actual}.");
        }
    }
}
