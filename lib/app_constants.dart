// =============================================================================
//  App-wide constants / feature flags
// =============================================================================

/// Global trial flag for gradient card backgrounds. Kept false so flipping it
/// on app-wide later is a one-line change. For now the gradient is applied to
/// the first two weeks of content (4 & 5) via [gradientForWeek] while we
/// refine the look before rolling it out to every week.
const bool kEnableGradientCards = false;

/// Whether a given week should use the soft gradient card background.
bool gradientForWeek(int week) => kEnableGradientCards || week == 4 || week == 5;
