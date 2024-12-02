class MyFormValidator {
  //name Validation
  static String? validateName({required String name}) {
    if (name.length < 2) {
      return "Name Must be more than two character";
    } else {
      return null;
    }
  }

  static String? phone({required String phone}) {
    if (phone.length < 10 || phone.length > 10) {
      return "Invalid Phone #";
    } else {
      return null;
    }
  }

  //Password Validation
  static String? validatePassword({required String password}) {
    if (password.length < 6) {
      return "Password must be more than 5 characters";
    } else {
      return null;
    }
  }

  //Email Validation
  static String? validateEmail({required String email}) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(email)) {
      return "Enter Valid Email";
    } else {
      return null;
    }
  }
}
