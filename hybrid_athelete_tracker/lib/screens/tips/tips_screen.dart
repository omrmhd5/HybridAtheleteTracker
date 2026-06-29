import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/chat_provider.dart';
import '../../providers/tips_provider.dart';

/// The "Tips" tab is the conversational AI coach — seeded with the weekly tip.
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _prompts = ['Why am I tired?', 'Plan tomorrow', 'Fix my protein'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _seed());
  }

  Future<void> _seed() async {
    final tips = context.read<TipsProvider>();
    final chat = context.read<ChatProvider>();
    await tips.fetchWeeklyTip();
    if (!mounted) return;
    if (chat.messages.isEmpty) {
      final intro = tips.currentTip?['tipText'] as String? ??
          'Hey — I looked at your week. Ask me anything about how your training and nutrition line up.';
      chat.addMessage(intro, isUser: false);
    }
  }

  void _send([String? text]) {
    final msg = (text ?? _controller.text).trim();
    if (msg.isEmpty) return;
    context.read<ChatProvider>().sendMessage(msg);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    if (chat.messages.isNotEmpty || chat.isLoading) _scrollToBottom();

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _intro(),
              const SizedBox(height: 6),
              for (final m in chat.messages) _bubble(m.text, m.isUser),
              if (chat.isLoading) _typing(),
            ],
          ),
        ),
        _composer(),
      ],
    );
  }

  Widget _intro() {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryDim,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: const Icon(Icons.auto_awesome, size: 22, color: AppColors.primary),
        ),
        const SizedBox(height: 7),
        Text('Your AI coach',
            style: AppTextStyles.sans(size: 15, weight: FontWeight.w700)),
        Text('Grounded in your last 7 days', style: AppTextStyles.caption),
      ],
    );
  }

  Widget _bubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          border: isUser
              ? null
              : Border.all(color: AppColors.surfaceBorder),
          boxShadow: isUser ? null : AppColors.shadowSm,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 16),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.sans(
            size: 13,
            height: 1.45,
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _typing() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.surfaceBorder),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _prompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 7),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_prompts[i]),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border:
                          Border.all(color: AppColors.surfaceBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(_prompts[i],
                        style: AppTextStyles.sans(
                            size: 13, color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 5, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask your coach…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: AppTextStyles.sans(size: 15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _send(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
