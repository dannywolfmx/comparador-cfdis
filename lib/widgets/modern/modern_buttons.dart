import 'package:flutter/material.dart';

/// Botón primario modernizado
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final ModernButtonStyle style;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.style = ModernButtonStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (style) {
      case ModernButtonStyle.filled:
        button = _buildFilledButton(context);
        break;
      case ModernButtonStyle.outlined:
        button = _buildOutlinedButton(context);
        break;
      case ModernButtonStyle.text:
        button = _buildTextButton(context);
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildFilledButton(BuildContext context) {
    if (icon != null) {
      return FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(text),
      );
    }

    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(text),
      );
    }

    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    if (icon != null) {
      return TextButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(text),
      );
    }

    return TextButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}

/// Floating Action Button modernizado
class ModernFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool extended;
  final String? label;

  const ModernFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.extended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}

/// Botón de acción con icono y color personalizado
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool compact;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    if (compact) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: effectiveColor,
        tooltip: label,
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}

/// Botón con badge
class BadgeButton extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onPressed;

  const BadgeButton({
    super.key,
    required this.child,
    this.badgeText,
    this.badgeColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );

    if (badgeText != null) {
      return Badge(
        label: Text(badgeText!),
        backgroundColor: badgeColor ?? theme.colorScheme.error,
        child: button,
      );
    }

    return button;
  }
}

/// Chip modernizado
class ModernChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final Color? color;
  final IconData? icon;

  const ModernChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    if (onDeleted != null) {
      return Chip(
        label: Text(label),
        onDeleted: onDeleted,
        backgroundColor: selected ? effectiveColor.withOpacity(0.2) : null,
        avatar: icon != null ? Icon(icon, size: 16) : null,
      );
    }

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      backgroundColor: effectiveColor.withOpacity(0.1),
      selectedColor: effectiveColor.withOpacity(0.2),
      avatar: icon != null ? Icon(icon, size: 16) : null,
    );
  }
}

/// Estilos de botón
enum ModernButtonStyle {
  filled,
  outlined,
  text,
}
