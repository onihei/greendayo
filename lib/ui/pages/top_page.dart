import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/top_provider.dart';
import 'package:greendayo/ui/fragments/dot_image.dart';
import 'package:greendayo/ui/fragments/footer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

final videoPlayerControllerProvider =
    FutureProvider.autoDispose<VideoPlayerController>((ref) async {
  final controller = VideoPlayerController.asset("assets/videos/cover.mp4");
  await controller.initialize();
  controller.setVolume(0);
  controller.play();
  controller.setLooping(true);
  final streamSubject = BehaviorSubject<bool>.seeded(false);
  controller.addListener(() {
    streamSubject.sink.add(controller.value.isPlaying);
  });

  streamSubject.stream.distinct().listen((event) {
    Future.delayed(const Duration(milliseconds: 500), () {
      FlutterNativeSplash.remove();
    });
  });

  ref.onDispose(() async {
    await controller.dispose();
    await streamSubject.close();
  });
  return controller;
});

class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final screenSize = MediaQuery.of(context).size;
    final controller = ref.watch(videoPlayerControllerProvider);

    final scrollController = ref.watch(scrollControllerProvider);
    final globalKey = ref.watch(globalKeyProvider("TopPage"));

    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        key: globalKey,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: controller.when(
                  data: (data) {
                    return SizedBox(
                      height: screenSize.height * 0.95,
                      child: VideoPlayer(data),
                    );
                  },
                  error: (error, trace) => Text(trace.toString()),
                  loading: () => SizedBox(
                    height: screenSize.height * 0.95,
                  ),
                ),
              ),
              DotImage(
                  child: SizedBox(
                width: double.infinity,
                height: screenSize.height * 0.95,
              )),
              SizedBox(
                height: screenSize.height * 0.8,
                child: Image.asset(
                  'assets/images/susi.png',
                ),
              ),
            ],
          ),
          _about(ref, screenSize),
          _game(ref, screenSize),
          _job(ref, screenSize),
          const Footer(),
        ],
      ),
    );
  }

  Widget _about(ref, screenSize) {
    final globalKey = ref.watch(globalKeyProvider("About"));
    return Container(
      key: globalKey,
      width: double.infinity,
      child: SizedBox(
        height: screenSize.height * 1.4,
        child: Stack(
          children: [
            CustomPaint(
              painter: _DounutPainter(screenSize),
            ),
            const Align(
              alignment: Alignment(0, -0.5),
              child: Text("すしぺろはみんなのフレンドパーク"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _game(ref, screenSize) {
    final globalKey = ref.watch(globalKeyProvider("Game"));
    return Container(
      key: globalKey,
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

  Widget _job(ref, screenSize) {
    final globalKey = ref.watch(globalKeyProvider("Job"));
    return Container(
      key: globalKey,
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
        stops: const [
          0.6,
          0.6,
          0.8,
          0.8,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(screenSize.width * 0.7, screenSize.height * -0.2),
        radius: screenSize.height * 1.8,
      ));

    final rect = Rect.fromLTRB(0, 0, screenSize.width, screenSize.height * 2.8);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
