import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/time_ago.dart';
import '../data/controllers/comment_controller.dart';
import '../data/models/comment_model.dart';

class CommentSheet extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const CommentSheet({
    super.key,
    required this.postId,
    required this.postOwnerId,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  late final CommentController controller;
  final TextEditingController inputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(CommentController(), tag: widget.postId);
    controller.init(widget.postId);
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    Get.delete<CommentController>(tag: widget.postId);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.6, // Thoda size badha diya
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) {

          scrollCtrl.addListener(() {
            if (scrollCtrl.position.pixels >= scrollCtrl.position.maxScrollExtent - 200) {
              controller.loadMore();
            }
          });

          return Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column( // Stack ki jagah Column use karein for better structure
              children: [
                /// ➖ TOP HANDLE LINE
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                /// 💬 COMMENTS LIST OR EMPTY STATE
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value && controller.mainComments.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.mainComments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "No comments yet",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                            const Text("Be the first to share what you think!",
                                style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: controller.mainComments.length + (controller.hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == controller.mainComments.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _buildComment(controller.mainComments[i]);
                      },
                    );
                  }),
                ),

                /// ⌨️ BOTTOM INPUT AREA
                _buildInputSection(context, scheme),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Helper for Input Area (To keep build clean)
  Widget _buildInputSection(BuildContext context, ColorScheme scheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// REPLY INFO
        Obx(() {
          if (controller.replyingToUsername.value == null) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: scheme.surfaceVariant.withOpacity(0.5),
            child: Row(
              children: [
                Expanded(child: Text("Replying to @${controller.replyingToUsername.value}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                GestureDetector(onTap: controller.cancelReply, child: const Icon(Icons.close, size: 18)),
              ],
            ),
          );
        }),

        /// INPUT BAR
        AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(top: BorderSide(color: scheme.outlineVariant.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputCtrl,
                    maxLines: null, // Auto-expand textfield
                    decoration: const InputDecoration(
                      hintText: "Add a comment…",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                Obx(() => IconButton(
                  icon: Icon(Icons.send, color: controller.isLoading.value ? Colors.grey : scheme.primary),
                  onPressed: controller.isLoading.value ? null : () {
                    if (inputCtrl.text.trim().isNotEmpty) {
                      controller.submit(inputCtrl.text.trim());
                      inputCtrl.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// COMMENT + REPLIES
  Widget _buildComment(CommentModel c) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final replies = controller.repliesOf(c.commentId);
      final isExpanded = controller.isExpanded(c.commentId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(c.user.photoUrl),
            ),
            title: Row(
              children: [
                Text(
                  c.user.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Text(
                  TimeAgo.format(c.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            subtitle: Text(c.text),

            /// ⋮ MENU
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'reply') {
                  controller.startReply(c);
                }

                if (v == 'edit') {
                  inputCtrl.text = c.text; // 🔥 PREFILL SAME INPUT
                  controller.startEdit(c, c.text);
                }

                if (v == 'delete') {
                  controller.delete(c);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'reply', child: Text("Reply")),
                if (c.user.uid == controller.currentUserId)
                  const PopupMenuItem(value: 'edit', child: Text("Edit")),
                if (controller.canDelete(c, widget.postOwnerId))
                  const PopupMenuItem(value: 'delete', child: Text("Delete")),
              ],
            ),
          ),

          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 70, bottom: 4),
              child: GestureDetector(
                onTap: () => controller.toggleReplies(c.commentId),
                child: Obx(
                  () => Text(
                    controller.isExpanded(c.commentId)
                        ? "Hide replies"
                        : "View replies (${replies.length})",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

          /// 🔁 REPLIES
          if (isExpanded)
            ...replies.map(
              (r) => Padding(
                padding: const EdgeInsets.only(left: 30),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(r.user.photoUrl),
                  ),
                  title: Row(
                    children: [
                      Text(r.user.username),
                      const SizedBox(width: 6),
                      Text(
                        TimeAgo.format(r.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: scheme.onSurface),
                      children: [
                        TextSpan(
                          text: "@${c.user.username} ",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                        TextSpan(text: r.text),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      // if (v == 'reply') controller.startReply(r);
                      if (v == 'edit') {
                        inputCtrl.text = r.text;
                        controller.startEdit(r, r.text);
                      }
                      if (v == 'delete') controller.delete(r);
                    },
                    itemBuilder: (_) => [
                      // const PopupMenuItem(value: 'reply', child: Text("Reply")),
                      if (r.user.uid == controller.currentUserId)
                        const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      if (controller.canDelete(r, widget.postOwnerId))
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
