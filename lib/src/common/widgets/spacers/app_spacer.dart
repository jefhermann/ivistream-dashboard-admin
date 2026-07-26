import 'package:gap/gap.dart';

class Spacers {
  Spacers._();


  static Gap get sw1 => const Gap(10);
  static Gap get sw2 => const Gap(20);
  static Gap get sw3 => const Gap(30);
  static Gap get sw4 => const Gap(40);
  static Gap get sw5 => const Gap(50);
  static Gap get sw6 => const Gap(60);
  static Gap get sw8 => const Gap(80);
  static Gap get sw10 => const Gap(100);
  static Gap get sw20 => const Gap(200);
  static Gap get sw30 => const Gap(300);

  static Gap space(double value) => Gap(value);

  static Gap get min => const Gap(20);
  static Gap get medium => const Gap(40);
  static Gap get large => const Gap(60);
}