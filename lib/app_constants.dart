// =============================================================================
//  App-wide constants / feature flags
// =============================================================================

/// Global flag for gradient card backgrounds. Now ON for every week - the soft
/// blush gradient (previewed on weeks 4 & 5) is rolled out app-wide.
const bool kEnableGradientCards = true;

/// Whether a given week should use the soft gradient card background.
bool gradientForWeek(int week) => kEnableGradientCards || week == 4 || week == 5;
