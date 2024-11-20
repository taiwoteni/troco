import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/groups/domain/repositories/friend-repository.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';
import 'package:troco/features/groups/presentation/collections_page/widgets/empty-screen.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/friends-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/groups-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/referrals-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/views/profile-screen.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/loading-profile.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/profile-body-widget.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/profile-header-widget.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';
import 'package:troco/features/wallet/domain/repository/wallet-repository.dart';

import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/animations/lottie.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../groups/domain/entities/group.dart';

class ViewProfileScreen extends ConsumerStatefulWidget {
  final Client client;
  const ViewProfileScreen({super.key, required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewProfileScreenState();
}

class _ViewProfileScreenState extends ConsumerState<ViewProfileScreen> {
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) => loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.background, body: newProfileUi());
  }

  Future<void> loadProfile() {
    bool failure = false;
    setState(() => error = false);

    return Future.wait(
            [loadUser(), loadGroups(), loadFriends(), loadReferrals()],
            eagerError: true)
        .timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        setState(() => error = true);
        throw Exception("Error Occurred");
      },
    ).onError<Exception>((error, stackTrace) {
      failure = true;
      setState(() => this.error = true);
      throw Exception(error);
    }).then(
      (values) {
        if (values == null || values.isEmpty) {
          setState(() => error = true);
          return;
        }
        final user = values.first as Client;
        final groups = values[1] as List<Group>;
        final friends = values[2] as List<Client>;
        final referrals = values.last as List<Referral>;

        ref.read(userProfileProvider.notifier).state = user;
        ref.read(groupsProfileProvider.notifier).state = groups;
        ref.read(friendsProfileProvider.notifier).state = friends;
        ref.read(referralsProfileProvider.notifier).state = referrals;

        if (failure) {
          return;
        }
        setState(() => loading = false);
      },
    );
  }

  Future<Client> loadUser() {
    return ApiInterface.findUser(userId: widget.client.userId).onError(
      (error, stackTrace) {
        throw Exception(error);
      },
    ).then(
      (response) {
        if (response.error) {
          setState(() {
            error = true;
            loading = true;
          });

          throw Exception(response.messageBody?["message"] ??
              "Unknown Error when getting user profile");
        }

        final user = Client.fromJson(json: response.messageBody!["data"]);

        return user;
      },
    );
  }

  Future<List<Client>> loadFriends() {
    return FriendRepository.getUsersFriends(userId: widget.client.userId)
        .onError(
      (error, stackTrace) {
        throw Exception(error);
      },
    ).then(
      (friends) {
        if (friends.error) {
          setState(() {
            error = true;
            loading = true;
          });
          throw Exception(friends.messageBody?["message"] ?? "Error occurred");
          return Future.error(Exception(friends.messageBody?["message"] ?? ""));
        }

        return ((friends.messageBody?["data"] ?? []) as List)
            .map((json) => Client.fromJson(json: json))
            .toList();
      },
    );
  }

  Future<List<Referral>> loadReferrals() {
    return WalletRepository.getUserReferrals(userId: widget.client.userId)
        .onError(
      (error, stackTrace) {
        throw Exception(error);
      },
    ).then(
      (referrals) {
        if (referrals.error) {
          setState(() {
            error = true;
            loading = true;
          });
          throw Exception(
              referrals.messageBody?["message"] ?? "Error occurred");
          return Future.error(
              Exception(referrals.messageBody?["message"] ?? ""));
        }

        return ((referrals.messageBody?["data"] ?? []) as List)
            .map((json) => Referral.fromJson(json: json))
            .toList();
      },
    );
  }

  Future<List<Group>> loadGroups() {
    return GroupRepo.getUserGroups(userId: widget.client.userId).onError(
      (error, stackTrace) {
        throw Exception("Error");
      },
    ).then(
      (groups) {
        if (groups.error) {
          setState(() {
            error = true;
            loading = true;
          });
          throw Exception(groups.messageBody?["message"] ?? "Error occurred");
        }

        return ((groups.messageBody?["data"] ?? []) as List)
            .map((json) => Group.fromJson(json: json))
            .toList();
      },
    );
  }

  Widget oldProfileUi() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          ProfileHeader(client: widget.client),
          ProfileBody(client: widget.client),
        ],
      ),
    );
  }

  Widget newProfileUi() {
    return SizedBox.square(
      dimension: double.maxFinite,
      child: AnimatedCrossFade(
        firstChild: error
            ? errorWidget()
            : error
                ? errorWidget()
                : LoadingProfile(
                    firstName: widget.client.firstName,
                  ),
        secondChild: const ProfileScreen(),
        crossFadeState:
            !loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 800),
        firstCurve: Curves.easeIn,
      ),
    );
  }

  Widget errorWidget() {
    return SizedBox.square(
      dimension: double.maxFinite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieWidget(
              lottieRes: AssetManager.lottieFile(name: "error"),
              size: const Size.square(IconSizeManager.extralarge * 2)),
          mediumSpacer(),
          Text(
            "Error occurred when loading profile",
            style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'Quicksand',
                fontWeight: FontWeightManager.medium,
                fontSize: FontSizeManager.regular * 1.1),
          ),
          regularSpacer(),
          GestureDetector(
            onTap: loadProfile,
            child: Text(
              "Retry?",
              style: TextStyle(
                color: ColorManager.accentColor,
                fontFamily: 'lato',
                fontWeight: FontWeightManager.medium,
                fontSize: FontSizeManager.regular * 1.1,
                decorationColor: ColorManager.accentColor,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }
}
