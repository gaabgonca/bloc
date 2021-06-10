import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/blocs/authentication/authentication_bloc.dart';
import 'package:flutter_todos/blocs/todos/file_storage.dart';
import 'package:flutter_todos/blocs/todos/repository.dart';
import 'package:flutter_todos/screens/login_home_page.dart';
import 'package:flutter_todos/screens/login_screen.dart';
import 'package:flutter_todos/screens/splash_page.dart';
import 'package:user_repository/user_repository.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/localization.dart';
import 'package:flutter_todos/blocs/blocs.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:flutter_todos/screens/screens.dart';
import 'package:path_provider/path_provider.dart';

import 'localization.dart';

class App extends StatelessWidget {
  const App({
    Key key,
    @required this.authenticationRepository,
    @required this.userRepository,
  }) : super(key: key);

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TodosBloc>(
            create: (context) {
              return TodosBloc(
                todosRepository: const TodosRepositoryFlutter(
                  fileStorage: const FileStorage(
                    '__flutter_bloc_app__',
                    getApplicationDocumentsDirectory,
                  ),
                ),
              )..add(TodosLoaded());
            }
          ),
          BlocProvider<TabBloc>(
            create: (context) => TabBloc(),
          ),
          BlocProvider<FilteredTodosBloc>(
            create: (context) => FilteredTodosBloc(
              todosBloc: BlocProvider.of<TodosBloc>(context),
            ),
          ),
          BlocProvider<StatsBloc>(
            create: (context) => StatsBloc(
              todosBloc: BlocProvider.of<TodosBloc>(context),
            ),
          ),
          BlocProvider<AuthenticationBloc>(
              create: (_) => AuthenticationBloc(
                    authenticationRepository: authenticationRepository,
                    userRepository: userRepository,
                  ))
        ],
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        FlutterBlocLocalizationsDelegate(),
      ],
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomeScreen.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                  (route) => false,
                );
                break;
              default:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
      routes: {
        ArchSampleRoutes.addTodo: (context) {
          return AddEditScreen(
            key: ArchSampleKeys.addTodoScreen,
            onSave: (task, note) {
              BlocProvider.of<TodosBloc>(context).add(
                TodoAdded(Todo(task, note: note)),
              );
            },
            isEditing: false,
          );
        },
      }
    );
  }
}

// class TodosApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: FlutterBlocLocalizations().appTitle,
//       theme: ArchSampleTheme.theme,
//       localizationsDelegates: [
//         ArchSampleLocalizationsDelegate(),
//         FlutterBlocLocalizationsDelegate(),
//       ],
//       routes: {
//         ArchSampleRoutes.home: (context) {
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider<TabBloc>(
//                 create: (context) => TabBloc(),
//               ),
//               BlocProvider<FilteredTodosBloc>(
//                 create: (context) => FilteredTodosBloc(
//                   todosBloc: BlocProvider.of<TodosBloc>(context),
//                 ),
//               ),
//               BlocProvider<StatsBloc>(
//                 create: (context) => StatsBloc(
//                   todosBloc: BlocProvider.of<TodosBloc>(context),
//                 ),
//               ),
//             ],
//             child: HomeScreen(),
//           );
//         },
//         ArchSampleRoutes.addTodo: (context) {
//           return AddEditScreen(
//             key: ArchSampleKeys.addTodoScreen,
//             onSave: (task, note) {
//               BlocProvider.of<TodosBloc>(context).add(
//                 TodoAdded(Todo(task, note: note)),
//               );
//             },
//             isEditing: false,
//           );
//         },
//       },
//     );
//   }
// }
