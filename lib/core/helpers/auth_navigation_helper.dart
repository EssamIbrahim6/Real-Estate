import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_state.dart';
import '../router/route_names.dart';

void handleAuthSuccessNavigation(BuildContext context, Authenticated state) {
  if (state.accountSetupCompleted) {
    context.go(AppRoutes.home);
  } else {
    context.go(AppRoutes.accountSetupLocation);
  }
}
