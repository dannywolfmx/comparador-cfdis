import 'package:flutter/material.dart';

/// Scaffold modernizado con navegación adaptativa
class ModernScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final List<ModernNavItem>? navigationItems;
  final int selectedIndex;
  final ValueChanged<int>? onNavigationChanged;
  final bool showNavigationRail;

  const ModernScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.drawer,
    this.navigationItems,
    this.selectedIndex = 0,
    this.onNavigationChanged,
    this.showNavigationRail = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: _buildBody(context, isMobile, isTablet),
      drawer: isMobile ? drawer : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildBottomNavigation(context, isMobile),
    );
  }

  PreferredSizeWidget? _buildAppBar(ThemeData theme) {
    if (title == null && (actions?.isEmpty ?? true)) return null;

    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  Widget _buildBody(BuildContext context, bool isMobile, bool isTablet) {
    if (navigationItems == null || isMobile) {
      return body;
    }

    // Desktop/tablet with navigation rail
    return Row(
      children: [
        _buildNavigationRail(context, isTablet),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildNavigationRail(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationChanged,
      extended: !isTablet,
      destinations: navigationItems!.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
          label: Text(item.label),
        );
      }).toList(),
      backgroundColor: theme.colorScheme.surface,
      elevation: 1,
    );
  }

  Widget? _buildBottomNavigation(BuildContext context, bool isMobile) {
    if (navigationItems == null || !isMobile) return null;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationChanged,
      destinations: navigationItems!.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}

/// Drawer modernizado
class ModernDrawer extends StatelessWidget {
  final List<ModernDrawerItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final Widget? header;

  const ModernDrawer({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onItemSelected,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          if (header != null)
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: header,
            ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return ListTile(
                  leading: Icon(
                    isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    item.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.secondaryContainer,
                  onTap: () => onItemSelected?.call(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Layout responsivo para contenido principal
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200 && desktop != null) {
      return desktop!;
    } else if (screenWidth >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// Container con máximo ancho para contenido
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Elemento de navegación
class ModernNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? tooltip;

  const ModernNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });
}

/// Elemento del drawer
class ModernDrawerItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final VoidCallback? onTap;

  const ModernDrawerItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.onTap,
  });
}
