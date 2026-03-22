import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unigpa/core/constants/app_colors.dart';
import 'package:unigpa/core/constants/app_text_styles.dart';
import 'package:unigpa/core/utils/gpa_calculator.dart';
import 'package:unigpa/core/widgets/app_button.dart';
import 'package:unigpa/core/widgets/app_card.dart';
import 'package:unigpa/core/widgets/app_text_field.dart';

class TargetGpaCalculator extends StatefulWidget {
  const TargetGpaCalculator({
    super.key,
    required this.currentGPA,
    required this.currentCredits,
  });

  final double currentGPA;
  final int currentCredits;

  @override
  State<TargetGpaCalculator> createState() => _TargetGpaCalculatorState();
}

class _TargetGpaCalculatorState extends State<TargetGpaCalculator> {
  final _targetCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();
  final _manualGpaCtrl = TextEditingController();
  final _manualTcCtrl = TextEditingController();

  bool _useAppData = true;
  bool _inputRemaining = true;

  double get _effectiveGPA => _useAppData
      ? widget.currentGPA
      : (double.tryParse(_manualGpaCtrl.text.replaceAll(',', '.')) ?? 0);
  int get _effectiveCredits => _useAppData
      ? widget.currentCredits
      : (int.tryParse(_manualTcCtrl.text) ?? 0);

  bool get _isValid {
    final target = double.tryParse(_targetCtrl.text.replaceAll(',', '.'));
    if (target == null || target <= 0 || target > 4.0) return false;

    final inputTC = int.tryParse(_creditsCtrl.text);
    if (inputTC == null || inputTC <= 0) return false;

    if (!_useAppData) {
      final gpa = double.tryParse(_manualGpaCtrl.text.replaceAll(',', '.'));
      if (gpa == null || gpa < 0 || gpa > 4.0) return false;

      final tc = int.tryParse(_manualTcCtrl.text);
      if (tc == null || tc <= 0) return false;
    }

    if (!_inputRemaining) {
      if (inputTC <= _effectiveCredits) return false;
    }

    return true;
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _creditsCtrl.dispose();
    _manualGpaCtrl.dispose();
    _manualTcCtrl.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  void _showResult() {
    final target = double.parse(_targetCtrl.text.replaceAll(',', '.'));
    final inputTC = int.parse(_creditsCtrl.text);
    final remaining = _inputRemaining ? inputTC : (inputTC - _effectiveCredits);

    if (remaining <= 0) {
      _showResultDialog(true, null);
      return;
    }

    final needed = GpaCalculator.calculateNeededGPA(
      currentGPA: _effectiveGPA,
      currentCredits: _effectiveCredits,
      targetGPA: target,
      remainingCredits: remaining,
    );

    _showResultDialog(needed == null, needed);
  }

  void _showResultDialog(bool impossible, double? neededGPA) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Center(
          child: Text(
            impossible ? '😢' : '🤩',
            style: const TextStyle(fontSize: 48),
          ),
        ),
        content: Text(
          impossible
              ? 'Không thể đạt được GPA mục tiêu!'
              : 'Cần đạt GPA ≥ ${neededGPA!.toStringAsFixed(2)} / 4.00',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.colors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Mục tiêu',
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _useAppData = !_useAppData;
                }),
                child: const Row(
                  children: [
                    Icon(
                      Icons.sync_alt_rounded,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_useAppData) ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _manualGpaCtrl,
                    label: 'GPA hiện tại',
                    hint: 'vd: 3.20',
                    onChanged: (_) => _onInputChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _manualTcCtrl,
                    label: 'TC tích lũy',
                    hint: 'vd: 60',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (_) => _onInputChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _targetCtrl,
                  label: 'GPA mục tiêu',
                  hint: 'vd: 3.20',
                  onChanged: (_) => _onInputChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _creditsCtrl,
                  label: _inputRemaining ? 'TC còn lại' : 'TC toàn khoá',
                  hint: _inputRemaining ? 'vd: 30' : 'vd: 120',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (_) => _onInputChanged(),
                  trailingLabel: GestureDetector(
                    onTap: () => setState(() {
                      _inputRemaining = !_inputRemaining;
                      _creditsCtrl.clear();
                      _onInputChanged();
                    }),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: _isValid ? _showResult : null,
              label: 'Tính điểm',
            ),
          ),
        ],
      ),
    );
  }
}
