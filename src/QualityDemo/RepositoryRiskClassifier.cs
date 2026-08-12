namespace QualityDemo;

public enum RepositoryRisk
{
    Low,
    Medium,
    High,
}

public sealed class RepositoryRiskClassifier
{
    public RepositoryRisk Classify(PullRequestSignal signal)
    {
        ArgumentNullException.ThrowIfNull(signal);

        int score = 0;
        score += signal.ChangedLines >= 500 ? 2 : signal.ChangedLines >= 100 ? 1 : 0;
        score += signal.CriticalAlerts * 3;
        score += signal.HighAlerts * 2;
        score += signal.CoveragePercent < 70m ? 2 : signal.CoveragePercent < 80m ? 1 : 0;
        score += signal.DuplicatedLinesPercent > 5m ? 1 : 0;

        return score switch
        {
            >= 5 => RepositoryRisk.High,
            >= 2 => RepositoryRisk.Medium,
            _ => RepositoryRisk.Low,
        };
    }
}
