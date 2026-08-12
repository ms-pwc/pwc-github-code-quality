namespace QualityDemo;

public sealed class QualityGateEvaluator
{
    public QualityGateDecision Evaluate(PullRequestSignal signal, QualityGateOptions options)
    {
        ArgumentNullException.ThrowIfNull(signal);
        ArgumentNullException.ThrowIfNull(options);

        List<string> reasons = [];

        if (signal.CriticalAlerts > 0)
        {
            reasons.Add("Critical code scanning alerts must be fixed before merge.");
        }

        if (signal.HighAlerts > options.MaximumHighAlerts)
        {
            reasons.Add($"High severity alerts must be <= {options.MaximumHighAlerts}.");
        }

        if (signal.CoveragePercent < options.MinimumCoveragePercent)
        {
            reasons.Add($"Coverage must be >= {options.MinimumCoveragePercent:0.#}%.");
        }

        if (signal.DuplicatedLinesPercent > options.MaximumDuplicatedLinesPercent)
        {
            reasons.Add($"Duplicated lines must be <= {options.MaximumDuplicatedLinesPercent:0.#}%.");
        }

        if (!signal.HasOwnerReview)
        {
            reasons.Add("CODEOWNERS review is required for changed areas.");
        }

        if (!signal.HasPassingBuild)
        {
            reasons.Add("All required GitHub Actions checks must pass.");
        }

        return reasons.Count == 0
            ? new QualityGateDecision(QualityGateStatus.Passed, Array.Empty<string>())
            : new QualityGateDecision(QualityGateStatus.Failed, reasons);
    }
}
