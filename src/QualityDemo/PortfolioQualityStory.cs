namespace QualityDemo;

public static class PortfolioQualityStory
{
    private static readonly decimal[] WeeklyCoverage =
    [
        62.1m, 63.0m, 64.2m, 63.8m, 64.5m, 65.4m, 66.1m, 66.9m, 67.4m, 67.0m,
        68.2m, 69.1m, 68.9m, 69.8m, 70.3m, 71.0m, 71.6m, 72.2m, 72.9m, 73.4m,
        73.0m, 73.8m, 74.5m, 75.2m, 75.9m, 76.4m, 77.1m, 77.8m, 78.2m, 78.9m,
        79.3m, 79.8m, 80.4m, 81.1m, 81.6m, 82.0m, 82.4m, 82.8m, 83.2m, 83.7m,
        84.1m, 84.5m, 84.8m, 85.0m, 85.3m, 85.7m, 86.0m, 86.2m, 86.4m, 86.6m
    ];

    private static readonly decimal[] WeeklyDuplication =
    [
        6.2m, 6.0m, 5.9m, 5.8m, 5.8m, 5.7m, 5.6m, 5.5m, 5.4m, 5.3m,
        5.2m, 5.1m, 5.0m, 4.9m, 4.8m, 4.7m, 4.7m, 4.6m, 4.5m, 4.4m,
        4.3m, 4.3m, 4.2m, 4.1m, 4.0m, 3.9m, 3.8m, 3.7m, 3.7m, 3.6m,
        3.5m, 3.4m, 3.4m, 3.3m, 3.2m, 3.1m, 3.1m, 3.0m, 3.0m, 2.9m,
        2.8m, 2.8m, 2.7m, 2.7m, 2.6m, 2.6m, 2.5m, 2.5m, 2.4m, 2.4m
    ];

    public static decimal CalculateAverageCoverage()
    {
        decimal total = 0m;

        foreach (decimal value in WeeklyCoverage)
        {
            total += value;
        }

        return Math.Round(total / WeeklyCoverage.Length, 2, MidpointRounding.AwayFromZero);
    }

    public static decimal CalculateCoverageMomentum(int windowSize)
    {
        if (windowSize <= 0 || windowSize >= WeeklyCoverage.Length)
        {
            throw new ArgumentOutOfRangeException(nameof(windowSize));
        }

        decimal olderWindowAverage = AverageSlice(WeeklyCoverage, WeeklyCoverage.Length - (windowSize * 2), windowSize);
        decimal newerWindowAverage = AverageSlice(WeeklyCoverage, WeeklyCoverage.Length - windowSize, windowSize);

        return Math.Round(newerWindowAverage - olderWindowAverage, 2, MidpointRounding.AwayFromZero);
    }

    public static decimal CalculateDuplicationTrend(int windowSize)
    {
        if (windowSize <= 0 || windowSize >= WeeklyDuplication.Length)
        {
            throw new ArgumentOutOfRangeException(nameof(windowSize));
        }

        decimal olderWindowAverage = AverageSlice(WeeklyDuplication, WeeklyDuplication.Length - (windowSize * 2), windowSize);
        decimal newerWindowAverage = AverageSlice(WeeklyDuplication, WeeklyDuplication.Length - windowSize, windowSize);

        return Math.Round(newerWindowAverage - olderWindowAverage, 2, MidpointRounding.AwayFromZero);
    }

    public static string DerivePortfolioPosture()
    {
        decimal coverage = WeeklyCoverage[^1];
        decimal duplication = WeeklyDuplication[^1];

        if (coverage >= 85m && duplication <= 3m)
        {
            return "Strong";
        }

        if (coverage >= 75m && duplication <= 5m)
        {
            return "Improving";
        }

        if (coverage >= 65m)
        {
            return "Watch";
        }

        return "At risk";
    }

    public static IReadOnlyList<string> BuildReleaseNarrative()
    {
        List<string> lines =
        [
            "Coverage continued climbing with steady week-over-week gains.",
            "Duplication reduced through focused refactoring on shared modules.",
            "Security review throughput improved after ownership alignment.",
            "Critical vulnerabilities remain blocked by quality gate enforcement.",
            "Maintainability debt is being retired within sprint capacity.",
            "Hotspot triage now follows a strict 48-hour review SLA.",
            "Regression risk stayed stable despite higher deployment frequency.",
            "Overall portfolio quality posture is trending in the right direction."
        ];

        return lines;
    }

    private static decimal AverageSlice(decimal[] source, int start, int length)
    {
        decimal total = 0m;

        for (int index = start; index < start + length; index++)
        {
            total += source[index];
        }

        return total / length;
    }
}
