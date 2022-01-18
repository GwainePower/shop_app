import 'dart:math' as math;

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../models/http_exception.dart';

import '../providers/auth_provider.dart';

import '../widgets/error_message.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: deviceSize.width,
              height: deviceSize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 105),
                      transform: Matrix4.rotationZ(-8 * math.pi / 180)
                        ..translate(-7.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black38,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'МАГАЗИН :)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 38,
                          fontFamily: 'Tellural',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: const AuthCard(),
                    flex: deviceSize.width > 600 ? 2 : 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authdata = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController? _animController;
  // Все объекты Animation - генерики, должно быть указано, чё именно
  // нужно анимировать по значению
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // говно, не прокатит значит. НЕВАЛИДНО!
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    if (_authMode == AuthMode.login) {
      // при таком раскладе режим логина. ЛОГИНИМСЯ!
      try {
        await Provider.of<AuthProvider>(context, listen: false).signIn(
          _authdata['email']!,
          _authdata['password']!,
        );
        // Это не юзаем. Вместо пуша делаем логику в Main через Consumer
        // Navigator.of(context)
        //     .pushReplacementNamed(ProductsOverviewScreen.routeName);
      } on HttpException catch (error) {
        var errorMessage = 'всё накрылось медным тазом и ничего не получилось';
        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessage = 'юзер с такой почтой уже есть';
        } else if (error.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
          errorMessage = 'слишком рьяно пытаешься';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessage = 'юзера с такой почтой у нас нет, сорян';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessage = 'пароль неправильный, глянь нормально чё там';
        }
        print(errorMessage);
        await showDialog(
          context: context,
          builder: (ctx) => ErrorMessage(error: errorMessage),
        );
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => ErrorMessage(error: error),
        );
      }
    } else {
      // а иначе регаем нового юзера
      try {
        await Provider.of<AuthProvider>(context, listen: false).signUp(
          _authdata['email']!,
          _authdata['password']!,
        );
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => ErrorMessage(error: error),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() => _authMode = AuthMode.signup);
      _animController!.forward();
    } else {
      setState(() => _authMode = AuthMode.login);
      _animController!.reverse();
    }
  }

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Использовалось чтобы растягивать контейнер ввода данных
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
        CurvedAnimation(parent: _animController!, curve: Curves.fastOutSlowIn));
    // Используем для плавного вывода строки повтора пароля
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController!,
        curve: Curves.easeIn,
      ),
    );
    // Вместо добавления листенера делаем AnimatedBuilder ниже
    // _heightAnimation!.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _animController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.signup ? 320 : 260,
        // height: _heightAnimation!.value.height,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signup ? 320 : 260),
        // BoxConstraints(minHeight: _heightAnimation!.value.height),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Введите адрес эл. почты'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Эмэил введи ё-моё';
                    }
                  },
                  onSaved: (newValue) => _authdata['email'] = newValue!,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Введите пароль'),
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Слишком короткий пароль';
                    }
                  },
                  onSaved: (newValue) => _authdata['password'] = newValue!,
                ),
                // if (_authMode == AuthMode.signup)
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signup ? 120 : 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Повторите пароль'),
                        obscureText: true,
                        validator: _authMode == AuthMode.signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Пароли не совпадают!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _submit(),
                        child: Text(_authMode == AuthMode.login
                            ? 'ВОЙТИ'
                            : 'ЗАРЕГАТЬСЯ'),
                        style: ElevatedButton.styleFrom(
                          onPrimary: Theme.of(context).primaryColor,
                          textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .button!
                                  .color),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 30,
                          ),
                        ),
                      ),
                TextButton(
                  onPressed: () => _switchAuthMode(),
                  child: Text(
                      'Не, я всё же хочу ${_authMode == AuthMode.login ? 'зарегаться' : 'войти'}!'),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 4,
                    ),
                    primary: Theme.of(context).primaryColorLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
