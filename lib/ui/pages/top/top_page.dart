import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/ui/fragments/dot_image.dart';
import 'package:greendayo/ui/fragments/footer.dart';
import 'package:greendayo/ui/fragments/login_dialog.dart';
import 'package:greendayo/ui/fragments/showy_button.dart';
import 'package:greendayo/ui/fragments/spiral_container.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

part 'top_page.g.dart';

@riverpod
Future<VideoPlayerController> _videoPlayerController(Ref ref) async {
  final controller = VideoPlayerController.asset("assets/videos/cover.mp4");
  await controller.initialize();
  await controller.setVolume(0);
  await controller.play();
  await controller.setLooping(true);
  FlutterNativeSplash.remove();
  ref.onDispose(() async {
    await controller.dispose();
  });
  return controller;
}

@riverpod
class _ViewController extends _$ViewController {
  final aboutKey = GlobalKey();
  final gamesKey = GlobalKey();
  final historiesKey = GlobalKey();
  final jobsKey = GlobalKey();

  @override
  _ViewController build() {
    return this;
  }

  void scrollToTop(ScrollController scrollController) {
    scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void scrollToAbout(ScrollController scrollController) {
    _scrollTo(aboutKey);
  }

  void scrollToGames(ScrollController scrollController) {
    _scrollTo(gamesKey);
  }

  void scrollToJobs(ScrollController scrollController) {
    _scrollTo(jobsKey);
  }

  void _scrollTo(GlobalKey targetKey) {
    final context = targetKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LoginDialog(),
    );
  }
}

class TopPage extends StatefulHookConsumerWidget {
  final String? userId;
  const TopPage({super.key, this.userId});

  @override
  ConsumerState<TopPage> createState() => _TopPageState();
}

class _TopPageState extends ConsumerState<TopPage> {
  _TopPageState();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final success = await showDialog(
          context: context,
          builder: (context) => LoginDialog(),
        );
        if (success == true) {
          ref.read(selectedUserIdProvider.notifier).select(widget.userId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = ref.watch(_viewControllerProvider);
    final scrollController = useScrollController();
    final scrollPosition = useState(0.0);
    scrollController.addListener(() {
      scrollPosition.value = scrollController.position.pixels;
    });
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(1000, 200),
        child: _appBar(context, ref, scrollController),
      ),
      body: _body(context, ref, scrollController),
      floatingActionButton: scrollPosition.value > 100
          ? FloatingActionButton(
              child: const Icon(Icons.arrow_upward),
              onPressed: () {
                vc.scrollToTop(scrollController);
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _appBar(
    BuildContext context,
    ref,
    ScrollController scrollController,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final screenSize = MediaQuery.of(context).size;
    final scrollPosition = useState(0.0);
    scrollController.addListener(() {
      scrollPosition.value = scrollController.position.pixels;
    });
    double opacity = scrollPosition.value < screenSize.height * 0.95
        ? scrollPosition.value / (screenSize.height * 0.95)
        : 1;
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 1 - opacity),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width / 70),
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            vc.scrollToAbout(scrollController);
                          },
                          child: const Text('すしぺろについて'),
                        ),
                        SizedBox(width: screenSize.width / 50),
                        TextButton(
                          onPressed: () {
                            vc.scrollToGames(scrollController);
                          },
                          child: const Text('ゲーム'),
                        ),
                        SizedBox(width: screenSize.width / 50),
                        TextButton(
                          onPressed: () {
                            vc.scrollToJobs(scrollController);
                          },
                          child: const Text('仕事の依頼'),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
            TextButton(
              onPressed: () async {
                vc.showLoginDialog(context);
              },
              child: const Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
      BuildContext context, WidgetRef ref, ScrollController scrollController) {
    final vc = ref.watch(_viewControllerProvider);
    final screenSize = MediaQuery.of(context).size;
    final videoControllerAsync = ref.watch(_videoPlayerControllerProvider);

    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: videoControllerAsync.when(
                  data: (videoController) {
                    return SizedBox(
                      height: screenSize.height * 0.95,
                      child: VideoPlayer(videoController),
                    );
                  },
                  error: (error, stackTrace) => Text(error.toString() ?? ''),
                  loading: () => SizedBox(height: screenSize.height * 0.95),
                ),
              ),
              Positioned.fill(child: DotImage()),
              SizedBox(
                height: screenSize.height * 0.8,
                child: Image.asset('assets/images/susi.png'),
              ),
            ],
          ),
          _about(ref, screenSize),
          _game(ref, screenSize),
          _getStart(context, ref, screenSize),
          _histories(context, ref, screenSize),
          _job(ref, screenSize),
          const Footer(),
        ],
      ),
    );
  }

  Widget _about(ref, screenSize) {
    final vc = ref.watch(_viewControllerProvider);
    return Container(
      key: vc.aboutKey,
      width: double.infinity,
      child: SizedBox(
        height: screenSize.height * 1.4,
        child: Stack(
          children: [
            CustomPaint(painter: _DounutPainter(screenSize)),
            const Align(
              alignment: Alignment(0, -0.5),
              child: Text("すしぺろはみんなのフレンドパーク"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStart(BuildContext context, WidgetRef ref, screenSize) {
    return Container(
      width: double.infinity,
      child: SizedBox(
        height: screenSize.height * 1.4,
        child: Align(
          alignment: Alignment(0, -0.5),
          child: ShowyButton(
            child: Text("Get Started"),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => LoginDialog(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _game(ref, screenSize) {
    final vc = ref.watch(_viewControllerProvider);
    return Container(
      key: vc.gamesKey,
      width: double.infinity,
      color: Colors.indigo[800],
      child: SizedBox(
        height: screenSize.height * 1.4,
        child: Align(
          alignment: const Alignment(0, -0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ゲーム"),
              Padding(
                padding: EdgeInsets.only(
                  top: screenSize.height * 0.06,
                  left: screenSize.width / 15,
                  right: screenSize.width / 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: screenSize.width / 6,
                      width: screenSize.width / 3.8,
                      child: InkWell(
                        onTap: () {
                          launchUrlString("https://susipero.com/battlechat/");
                        },
                        child: const Text("バトルチャット"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _histories(BuildContext context, WidgetRef ref, screenSize) {
    final vc = ref.watch(_viewControllerProvider);
    return Container(
      key: vc.historiesKey,
      width: double.infinity,
      child: SizedBox(
        height: screenSize.height * 1.4,
        child: SpiralContainer(),
      ),
    );
  }

  Widget _job(ref, screenSize) {
    final vc = ref.watch(_viewControllerProvider);
    return Container(
      key: vc.jobsKey,
      width: double.infinity,
      color: Colors.teal[800],
      child: SizedBox(
        height: screenSize.height * 1.4,
        child: const Align(
          alignment: Alignment(0, -0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("お仕事の依頼を募集しています。"),
              // SizedBox(
              //   width: 400,
              //   height: 400,
              //   child: ModelViewer(
              //     cameraControls: false,
              //     // fixme : bug?
              //     src: kIsWeb ? 'assets/assets/models/rock.glb' : 'assets/models/rock.glb',
              //     alt: "A 3D model of an astronaut",
              //     autoRotate: true,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DounutPainter extends CustomPainter {
  _DounutPainter(this.screenSize);

  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(180, 0, 0, 0)
      ..shader = RadialGradient(
        colors: [
          Colors.deepOrange[900]!,
          Colors.brown[900]!,
          Colors.brown[900]!,
          Colors.transparent,
        ],
        stops: const [0.6, 0.6, 0.8, 0.8],
      ).createShader(
        Rect.fromCircle(
          center: Offset(screenSize.width * 0.7, screenSize.height * -0.2),
          radius: screenSize.height * 1.8,
        ),
      );

    final rect = Rect.fromLTRB(0, 0, screenSize.width, screenSize.height * 2.8);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
