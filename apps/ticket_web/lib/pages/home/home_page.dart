import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ticket_web/core/components/site_scaffold.dart';
import 'package:ticket_web/feature/auth/data/auth_notifier.dart';
import 'package:ticket_web/gen/i18n/strings.g.dart';
import 'package:ticket_web/pages/home/components/already_logged_in_card.dart';
import 'package:ticket_web/pages/home/components/login_before_purchase_card.dart';
import 'package:ticket_web/pages/home/components/ticket_cards.dart';
import 'package:ticket_web/pages/home/components/ticket_cards/information_for_students.dart';
import 'package:ticket_web/pages/home/components/title_and_logo.dart';
import 'package:ticket_web/pages/home/components/transit_to_home_page.dart';

part 'home_page.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
)
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteScaffold.widget(
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TitleAndLogo(),
          ),
          TransitToHomePage(),
          SizedBox(height: 48),
          _AuthStateCard(),
          TicketCards(),
          SizedBox(height: 8),
          InformationForStudents(),
          SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _AuthStateCard extends ConsumerWidget {
  const _AuthStateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    final Widget child;
    if (authState == null) {
      child = LoginBeforePurchaseCard(
        key: const ValueKey('LoginBeforePurchaseCard'),
        onSignInPressed:
            ref.watch(authNotifierProvider.notifier).signInWithGoogle,
      );
    } else {
      child = AlreadyLoggedInCard(
        key: const ValueKey('AlreadyLoggedInCard'),
        mailAddress: authState.email ?? '',
        onLogOutPressed: () async {
          final i18n = Translations.of(context);
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final shouldSignOut = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(i18n.authorization.logOutDialog.title),
              content: Text(i18n.authorization.logOutDialog.description),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(i18n.authorization.logOutDialog.cancel),
                ),
                TextButton(
                  onPressed: () => context.pop(true),
                  child: Text(
                    i18n.authorization.logOutDialog.logout,
                    style: TextStyle(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          );
          if (shouldSignOut != null && shouldSignOut) {
            await ref.read(authNotifierProvider.notifier).signOut();
          }
        },
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      layoutBuilder: (currentChild, previousChild) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChild,
          if (currentChild != null) currentChild,
        ],
      ),
      child: child,
    );
  }
}
