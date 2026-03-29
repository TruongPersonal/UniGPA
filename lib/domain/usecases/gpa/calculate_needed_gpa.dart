

class CalculateNeededGpa {
  double? call({
    required double currentGPA,
    required int currentCredits,
    required double targetGPA,
    required int remainingCredits,
  }) {
    if (remainingCredits <= 0) return null;

    final needed =
        (targetGPA * (currentCredits + remainingCredits) -
            currentGPA * currentCredits) /
        remainingCredits;

    if (needed < 1.0 || needed > 4.0) return null;
    return needed;
  }
}
