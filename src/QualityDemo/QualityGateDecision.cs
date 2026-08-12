namespace QualityDemo;

public enum QualityGateStatus
{
    Passed,
    Failed,
}

public sealed record QualityGateDecision(QualityGateStatus Status, IReadOnlyList<string> Reasons)
{
    public bool IsPassed => Status == QualityGateStatus.Passed;
}
