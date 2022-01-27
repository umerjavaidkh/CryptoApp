

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cryptotracker/repositories/crypto_repository.dart';


class AlertUserOnLimit {

  CryptoRepository cryptoRepository;

  AlertUserOnLimit({required this.cryptoRepository});

  void notifyUserIfLimitReached({required  double currentValue})async{

    var minLimit = await cryptoRepository.getMinRateLimit();
    var maxLimit = await cryptoRepository.getMaxRateLimit();


    if(currentValue<=minLimit){

      notifyUser("Min Limit Reached","Min limit of ${currentValue} USD is reached you can buy or sell your coin");
    }

    if(currentValue>=maxLimit){

      notifyUser("Max Limit Reached","Max limit of ${currentValue} USD is reached you can buy or sell your coin");

    }

  }

  void notifyUser(String title, String description){

    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            displayOnForeground: true,
            channelKey: 'basic_channel',
            title: title,
            body: description,
            payload: {'uuid': 'user-profile-uuid'}),
        actionButtons: [

          NotificationActionButton(
              key: 'PROFILE',
              label: 'View Details',
              enabled: true,
              buttonType: ActionButtonType.Default)
        ]);
  }

}