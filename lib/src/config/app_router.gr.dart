// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddContentScreen]
class AddContentRoute extends PageRouteInfo<void> {
  const AddContentRoute({List<PageRouteInfo>? children})
      : super(AddContentRoute.name, initialChildren: children);

  static const String name = 'AddContentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddContentScreen();
    },
  );
}

/// generated route for
/// [AdminTeamScreen]
class AdminTeamRoute extends PageRouteInfo<void> {
  const AdminTeamRoute({List<PageRouteInfo>? children})
      : super(AdminTeamRoute.name, initialChildren: children);

  static const String name = 'AdminTeamRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminTeamScreen();
    },
  );
}

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
      : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [ContentDetailScreen]
class ContentDetailRoute extends PageRouteInfo<ContentDetailRouteArgs> {
  ContentDetailRoute({
    Key? key,
    required String contentId,
    List<PageRouteInfo>? children,
  }) : super(
          ContentDetailRoute.name,
          args: ContentDetailRouteArgs(key: key, contentId: contentId),
          initialChildren: children,
        );

  static const String name = 'ContentDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ContentDetailRouteArgs>();
      return ContentDetailScreen(key: args.key, contentId: args.contentId);
    },
  );
}

class ContentDetailRouteArgs {
  const ContentDetailRouteArgs({this.key, required this.contentId});

  final Key? key;

  final String contentId;

  @override
  String toString() {
    return 'ContentDetailRouteArgs{key: $key, contentId: $contentId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContentDetailRouteArgs) return false;
    return key == other.key && contentId == other.contentId;
  }

  @override
  int get hashCode => key.hashCode ^ contentId.hashCode;
}

/// generated route for
/// [ContentGenderScreen]
class ContentGenderRoute extends PageRouteInfo<void> {
  const ContentGenderRoute({List<PageRouteInfo>? children})
      : super(ContentGenderRoute.name, initialChildren: children);

  static const String name = 'ContentGenderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ContentGenderScreen();
    },
  );
}

/// generated route for
/// [ContentsScreen]
class ContentsRoute extends PageRouteInfo<void> {
  const ContentsRoute({List<PageRouteInfo>? children})
      : super(ContentsRoute.name, initialChildren: children);

  static const String name = 'ContentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ContentsScreen();
    },
  );
}

/// generated route for
/// [ContentsWrapperPage]
class ContentsWrapperRoute extends PageRouteInfo<void> {
  const ContentsWrapperRoute({List<PageRouteInfo>? children})
      : super(ContentsWrapperRoute.name, initialChildren: children);

  static const String name = 'ContentsWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ContentsWrapperPage();
    },
  );
}

/// generated route for
/// [CountryScreen]
class CountryRoute extends PageRouteInfo<void> {
  const CountryRoute({List<PageRouteInfo>? children})
      : super(CountryRoute.name, initialChildren: children);

  static const String name = 'CountryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CountryScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [DashboardShellScreen]
class DashboardShellRoute extends PageRouteInfo<void> {
  const DashboardShellRoute({List<PageRouteInfo>? children})
      : super(DashboardShellRoute.name, initialChildren: children);

  static const String name = 'DashboardShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardShellScreen();
    },
  );
}

/// generated route for
/// [EditContentScreen]
class EditContentRoute extends PageRouteInfo<EditContentRouteArgs> {
  EditContentRoute({
    Key? key,
    required AdminContentModel content,
    List<PageRouteInfo>? children,
  }) : super(
          EditContentRoute.name,
          args: EditContentRouteArgs(key: key, content: content),
          initialChildren: children,
        );

  static const String name = 'EditContentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditContentRouteArgs>();
      return EditContentScreen(key: args.key, content: args.content);
    },
  );
}

class EditContentRouteArgs {
  const EditContentRouteArgs({this.key, required this.content});

  final Key? key;

  final AdminContentModel content;

  @override
  String toString() {
    return 'EditContentRouteArgs{key: $key, content: $content}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditContentRouteArgs) return false;
    return key == other.key && content == other.content;
  }

  @override
  int get hashCode => key.hashCode ^ content.hashCode;
}

/// generated route for
/// [PersonScreen]
class PersonRoute extends PageRouteInfo<void> {
  const PersonRoute({List<PageRouteInfo>? children})
      : super(PersonRoute.name, initialChildren: children);

  static const String name = 'PersonRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PersonScreen();
    },
  );
}

/// generated route for
/// [ProducersScreen]
class ProducersRoute extends PageRouteInfo<void> {
  const ProducersRoute({List<PageRouteInfo>? children})
      : super(ProducersRoute.name, initialChildren: children);

  static const String name = 'ProducersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProducersScreen();
    },
  );
}

/// generated route for
/// [RevenuesScreen]
class RevenuesRoute extends PageRouteInfo<void> {
  const RevenuesRoute({List<PageRouteInfo>? children})
      : super(RevenuesRoute.name, initialChildren: children);

  static const String name = 'RevenuesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RevenuesScreen();
    },
  );
}

/// generated route for
/// [UsersScreen]
class UsersRoute extends PageRouteInfo<void> {
  const UsersRoute({List<PageRouteInfo>? children})
      : super(UsersRoute.name, initialChildren: children);

  static const String name = 'UsersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UsersScreen();
    },
  );
}
