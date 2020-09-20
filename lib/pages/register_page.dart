import 'package:chat_flutter/helpers/mostrar_alertas.dart';
import 'package:chat_flutter/services/auth_service.dart';
import 'package:chat_flutter/widgets/botn_azul.dart';
import 'package:chat_flutter/widgets/custom_imput.dart';
import 'package:chat_flutter/widgets/labels.dart';
import 'package:chat_flutter/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF2F2F2),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Logo(titulo: 'Register'),
                  _Form(),
                  Labels(
                    ruta: 'login',
                    text: 'Ingresa ahora!',
                    text2: '¿Ya tienes cuenta?',
                  ),
                  Text(
                    'Termino y codicones de uso',
                    style: TextStyle(fontWeight: FontWeight.w200),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: <Widget>[
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            keyboardType: TextInputType.name,
            textController: nameCtrl,
          ),
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            isPassword: true,
            textController: passCtrl,
          ),

          //TODO crear boton
          BotonAzul(
            text: 'Registrase',
            onPressed: authService.autenticando
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final registerOK = await authService.register(
                        nameCtrl.text, emailCtrl.text.trim(), passCtrl.text);

                    if (registerOK == true) {
                      //navegar otra pantalla, conectar con los sockets
                      Navigator.pushReplacementNamed(context, 'usuarios');
                    } else {
                      //mostrar alerta
                      mostrarAlerta(context, 'regitro Incorrecto', registerOK);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
