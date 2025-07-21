import 'package:flutter/material.dart';

/// Widget base para mejorar la accesibilidad de todos los componentes
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final String? semanticValue;
  final bool isButton;
  final bool isHeader;
  final bool isLink;
  final bool isTextField;
  final bool isImage;
  final bool isSelected;
  final bool isEnabled;
  final bool isExpandable;
  final bool isExpanded;
  final bool isLiveRegion;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? tooltip;
  final int? tabIndex;
  final bool excludeSemantics;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.semanticValue,
    this.isButton = false,
    this.isHeader = false,
    this.isLink = false,
    this.isTextField = false,
    this.isImage = false,
    this.isSelected = false,
    this.isEnabled = true,
    this.isExpandable = false,
    this.isExpanded = false,
    this.isLiveRegion = false,
    this.onTap,
    this.onLongPress,
    this.tooltip,
    this.tabIndex,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Añadir tooltip si está disponible
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: result,
      );
    }

    // Aplicar semántica
    if (!excludeSemantics) {
      result = Semantics(
        label: semanticLabel,
        hint: semanticHint,
        value: semanticValue,
        button: isButton,
        header: isHeader,
        link: isLink,
        textField: isTextField,
        image: isImage,
        selected: isSelected,
        enabled: isEnabled,
        expanded: isExpanded,
        liveRegion: isLiveRegion,
        onTap: onTap,
        onLongPress: onLongPress,
        child: result,
      );
    }

    return result;
  }
}

/// Widget para botones accesibles
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  final bool isExpanded;
  final ButtonStyle? style;
  final FocusNode? focusNode;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
    this.isExpanded = false,
    this.style,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      tooltip: tooltip,
      isButton: true,
      isSelected: isSelected,
      isExpanded: isExpanded,
      isEnabled: onPressed != null,
      onTap: onPressed,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        focusNode: focusNode,
        child: child,
      ),
    );
  }
}

/// Widget para iconos con botón accesibles
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  final Color? color;
  final double? iconSize;
  final FocusNode? focusNode;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
    this.color,
    this.iconSize,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleWidget(
      semanticLabel: semanticLabel ?? tooltip,
      semanticHint: semanticHint,
      tooltip: tooltip,
      isButton: true,
      isSelected: isSelected,
      isEnabled: onPressed != null,
      onTap: onPressed,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
        color: color,
        iconSize: iconSize,
        focusNode: focusNode,
      ),
    );
  }
}

/// Widget para texto accesible con diferentes roles semánticos
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isHeader;
  final bool isLiveRegion;
  final String? semanticLabel;
  final String? semanticHint;
  final TextAlign? textAlign;
  final int? maxLines;

  const AccessibleText({
    super.key,
    required this.text,
    this.style,
    this.isHeader = false,
    this.isLiveRegion = false,
    this.semanticLabel,
    this.semanticHint,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleWidget(
      semanticLabel: semanticLabel ?? text,
      semanticHint: semanticHint,
      isHeader: isHeader,
      isLiveRegion: isLiveRegion,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }
}

/// Widget para campos de entrada accesibles
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final InputDecoration? decoration;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.semanticHint,
    this.isRequired = false,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = decoration ?? InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      border: const OutlineInputBorder(),
    );

    return AccessibleWidget(
      semanticLabel: semanticLabel ?? labelText ?? hintText,
      semanticHint: semanticHint ?? (isRequired ? 'Campo obligatorio' : null),
      isTextField: true,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines ?? 1,
        onChanged: onChanged,
        onTap: onTap,
        focusNode: focusNode,
        decoration: effectiveDecoration,
      ),
    );
  }
}

/// Widget para tarjetas accesibles
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
    this.color,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      color: color,
      margin: margin,
      child: padding != null 
        ? Padding(padding: padding!, child: child)
        : child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      );
    }

    return AccessibleWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      isButton: onTap != null,
      isSelected: isSelected,
      onTap: onTap,
      child: cardContent,
    );
  }
}

/// Widget para listas accesibles
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isSelected;
  final bool enabled;

  const AccessibleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      isButton: onTap != null || onLongPress != null,
      isSelected: isSelected,
      isEnabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        selected: isSelected,
        enabled: enabled,
      ),
    );
  }
}
