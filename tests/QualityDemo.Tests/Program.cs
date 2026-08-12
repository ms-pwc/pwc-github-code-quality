using QualityDemo;

TestRunner.Run(
    ("passes when all GitHub quality signals are clean", QualityGatePassesForCleanPullRequest),
    ("fails when security, coverage, duplication, or review gates fail", QualityGateExplainsFailures),
    ("classifies large risky pull requests as high risk", RiskClassifierFlagsHighRiskChanges),
    ("classifies small clean pull requests as low risk", RiskClassifierKeepsSmallCleanChangesLowRisk));

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
