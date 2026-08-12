namespace QualityDemo;

public sealed record PullRequestSignal(
    string Repository,
    int ChangedLines,
    int CriticalAlerts,
    int HighAlerts,
    decimal CoveragePercent,
    decimal DuplicatedLinesPercent,
    bool HasOwnerReview,
    bool HasPassingBuild);
