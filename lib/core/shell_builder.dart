
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class IndexedStackBranchContainer extends StatelessWidget {
  const IndexedStackBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> stackItems = children
        .mapIndexed((int index, Widget child) =>
        _buildRouteBranchContainer(context, currentIndex == index, child))
        .toList();

    return LocalIndexedStack(
      index: currentIndex,
      children: stackItems,
    );
  }

  Widget _buildRouteBranchContainer(
      BuildContext context, bool isActive, Widget child) {
    return Offstage(
      offstage: !isActive,
      child: TickerMode(
        enabled: isActive,
        child: child,
      ),
    );
  }
}

class LocalIndexedStack extends StatelessWidget {
  const LocalIndexedStack({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.clipBehavior = Clip.hardEdge,
    this.sizing = StackFit.loose,
    this.index = 0,
    this.children = const <Widget>[],
  });

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final Clip clipBehavior;
  final StackFit sizing;
  final int? index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final List<Widget> wrappedChildren =
    List<Widget>.generate(children.length, (int i) {
      return Visibility(
        visible: i == index,
        child: children[i],
      );
    });
    return _RawIndexedStack(
      alignment: alignment,
      textDirection: textDirection,
      clipBehavior: clipBehavior,
      sizing: sizing,
      index: index,
      children: wrappedChildren,
    );
  }
}

class _RawIndexedStack extends Stack {
  const _RawIndexedStack({
    super.alignment,
    super.textDirection,
    super.clipBehavior,
    StackFit sizing = StackFit.loose,
    this.index = 0,
    super.children,
  }) : super(fit: sizing);

  final int? index;

  bool _debugCheckHasDirectionality(BuildContext context) {
    if (alignment is AlignmentDirectional && textDirection == null) {
      assert(debugCheckHasDirectionality(
        context,
        why: "to resolve the 'alignment' argument",
        hint: alignment == AlignmentDirectional.topStart
            ? "The default value for 'alignment' is AlignmentDirectional.topStart, which requires a text direction."
            : null,
        alternative:
        "Instead of providing a Directionality widget, another solution would be passing a non-directional 'alignment', or an explicit 'textDirection', to the $runtimeType.",
      ));
    }
    return true;
  }

  @override
  RenderIndexedStack createRenderObject(BuildContext context) {
    assert(_debugCheckHasDirectionality(context));
    return RenderIndexedStack(
      index: index,
      fit: fit,
      clipBehavior: clipBehavior,
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderIndexedStack renderObject) {
    assert(_debugCheckHasDirectionality(context));
    renderObject
      ..index = index
      ..fit = fit
      ..clipBehavior = clipBehavior
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _IndexedStackElement(this);
  }
}

class _IndexedStackElement extends MultiChildRenderObjectElement {
  _IndexedStackElement(_RawIndexedStack super.widget);

  @override
  _RawIndexedStack get widget => super.widget as _RawIndexedStack;

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    final int? index = widget.index;

    if (index != null && children.isNotEmpty) {
      visitor(children.elementAt(index));
    }
  }
}
