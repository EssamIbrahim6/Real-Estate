import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/core/router/route_names.dart';
import 'package:real_estate_app/features/agent/domain/entities/agent_entity.dart';
import 'package:real_estate_app/features/home/presentation/widgets/agent_card.dart';

void main() {
  testWidgets('opens the agent details route with the selected agent ID', (
    tester,
  ) async {
    const agent = AgentEntity(
      id: 'agent-document-id',
      userId: 'auth-user-id',
      agencyName: 'Cairo Homes',
      name: 'Nour Hassan',
      photoUrl: '',
      bio: '',
      yearsOfExperience: 4,
      rating: 4.5,
      reviewCount: 8,
      isVerified: true,
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: AgentCard(
              agent: agent,
              onTap: () => context.pushNamed(
                AppRoutes.agentDetailsName,
                pathParameters: {'agentId': agent.id},
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.agentDetails,
          name: AppRoutes.agentDetailsName,
          builder: (context, state) => Scaffold(
            body: Text('Agent profile: ${state.pathParameters['agentId']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('Nour Hassan'));
    await tester.pumpAndSettle();

    expect(find.text('Agent profile: agent-document-id'), findsOneWidget);
  });
}
