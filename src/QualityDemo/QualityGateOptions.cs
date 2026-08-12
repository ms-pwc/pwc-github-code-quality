namespace QualityDemo;

public sealed record QualityGateOptions(
    decimal MinimumCoveragePercent,
    decimal MaximumDuplicatedLinesPercent,
    int MaximumHighAlerts)
{
    public static QualityGateOptions Recommended => new(80m, 3m, 0);
}
