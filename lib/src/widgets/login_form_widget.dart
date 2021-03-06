import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_cv_client_dart_common/blocs.dart';
import 'package:social_cv_client_dart_common/models.dart';
import 'package:social_cv_client_flutter/src/blocs/bloc_provider.dart';
import 'package:social_cv_client_flutter/src/blocs/login_bloc.dart';
import 'package:social_cv_client_flutter/src/localizations/cv_localization.dart';
import 'package:social_cv_client_flutter/src/utils/logger.dart';
import 'package:social_cv_client_flutter/src/utils/utils.dart';
import 'package:social_cv_client_flutter/src/utils/validators.dart';
import 'package:social_cv_client_flutter/src/widgets/error_widget.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  _LoginFormState() {
    loginBloc = LoginBloc();
  }

  LoginBloc loginBloc;

  @override
  Widget build(BuildContext context) {
    logger.info('Building LoginForm');

    AccountBloc _accountBloc = BlocProvider.of<AccountBloc>(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      children: <Widget>[
        SizedBox(height: 40.0),
        Column(
          children: <Widget>[
            Image.asset('images/account_card_details-blue.png'),
            SizedBox(height: 16.0),
            Text(
              CVLocalizations.of(context).appName,
              style: Theme.of(context).textTheme.title,
            ),
          ],
        ),
        const SizedBox(height: 120.0),
        BlocProvider<LoginBloc>(
          bloc: loginBloc,
          child: _LoginFormEmailInput(),
        ),
        const SizedBox(height: 12.0),
        BlocProvider<LoginBloc>(
          bloc: loginBloc,
          child: _LoginFormPasswordInput(),
        ),
        const SizedBox(height: 12.0),
        _LoginFromMessage(),
        ButtonBar(
          children: <Widget>[
            RaisedButton(
              child: Text(CVLocalizations.of(context).loginSignUpCTA),
              onPressed: null,
            ),
            StreamBuilder<bool>(
              initialData: false,
              stream: loginBloc.submitLoginStream,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return RaisedButton(
                    child: Text(CVLocalizations.of(context).loginSignInCTA),
                    onPressed: (snapshot.hasData && snapshot.data)
                        ? () => _accountBloc.login(
                            loginBloc.emailValue, loginBloc.passwordValue)
                        : null);
              },
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 2.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 16.0)),
            Text(
              CVLocalizations.of(context).loginOr,
              style: const TextStyle(fontSize: 18.0),
            ),
            const Padding(padding: EdgeInsets.only(left: 16.0)),
            Expanded(
              child: Container(
                height: 2.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 25.0)),
        Center(
          child: RaisedButton(
            onPressed: null,
            child: Text(CVLocalizations.of(context).loginSignInGoogleCTA),
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 16.0)),
        Center(
          child: RaisedButton(
            onPressed: null,
            child: Text(CVLocalizations.of(context).loginSignInFacebookCTA),
          ),
        ),
      ],
    );
  }
}

class _LoginFormEmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);

    return StreamBuilder(
      stream: loginBloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        String error;
        if (snapshot.hasError) {
          ValidationErrors errorType = snapshot.error;
          if (errorType == ValidationErrors.ERROR_LOGIN_NO_EMAIL) {
            error = CVLocalizations.of(context).loginNoEmailExplain;
          } else if (errorType == ValidationErrors.ERROR_LOGIN_NOT_EMAIL) {
            error = CVLocalizations.of(context).loginNotEmailExplain;
          }
        }
        return TextField(
          onChanged: loginBloc.changeEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: CVLocalizations.of(context).email + ' *',
            hintText: 'username@example.com',
            errorText: error,
          ),
        );
      },
    );
  }
}

class _LoginFormPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    return StreamBuilder(
      stream: loginBloc.passwordStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        String error;
        if (snapshot.hasError) {
          ValidationErrors errorType = snapshot.error;
          if (errorType == ValidationErrors.ERROR_LOGIN_NO_PASSWORD) {
            error = CVLocalizations.of(context).loginNoPasswordExplain;
          }
        }
        return TextField(
          onChanged: loginBloc.changePassword,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              labelText: CVLocalizations.of(context).password + ' *',
              errorText: error,
              suffixIcon: GestureDetector(
                onTap: loginBloc.toggleObscure,
                child: Icon(loginBloc.obscureValue
                    ? Icons.visibility
                    : Icons.visibility_off),
              )),
          obscureText: loginBloc.obscureValue,
        );
      },
    );
  }
}

class _LoginFromMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AccountBloc _accountBloc = BlocProvider.of<AccountBloc>(context);
    return StreamBuilder<UserModel>(
      stream: _accountBloc.accountDetailsStream,
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasError) {
          return ErrorCard(message: translateError(context, snapshot.error));
        } else if (snapshot.hasData) {
          return Card(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Text('Hello ${snapshot.data.username}'),
            ),
          );
        }
        return Container();
      },
    );
  }
}
