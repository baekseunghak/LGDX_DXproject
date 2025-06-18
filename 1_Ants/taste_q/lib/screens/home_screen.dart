import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:taste_q/screens/ble_scan_page_screen.dart';
import 'package:taste_q/screens/tasteq_main_screen.dart';
import 'package:taste_q/screens/fridge_main_screen.dart'; // 추가
import 'package:taste_q/views/front_appbar.dart'; // 기존 홈바 import 추가
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io' show Platform;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // 블루투스 설정 화면 진입 여부 체크 변수
  bool _wasBluetoothSettingsOpened = false;

  final List<Widget> _pages = const [
    HomeContent(key: PageStorageKey('home')),
    DeviceScreen(key: PageStorageKey('device')),
    ReportScreen(key: PageStorageKey('report')),
    MenuScreen(key: PageStorageKey('menu')),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wasBluetoothSettingsOpened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showCustomPopup(context, '기기와 연결되었습니다.');
        }
        _wasBluetoothSettingsOpened = false; // 다시 초기화
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색으로 설정
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Material(
        elevation: 8, // 그림자 효과 유지
        color: Colors.white, // 완전 흰색
        child: Padding(
          padding: const EdgeInsets.only(top: 4), // 상단 여백 줄여서 바가 위로 올라오게
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.devices), label: '디바이스'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '리포트'),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: '메뉴'),
            ],
          ),
        ),
      ),
    );
  }
}

// 기존 Home 화면 콘텐츠는 아래로 분리
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 상위 HomeScreen의 State에 접근하기 위해서 아래와 같이 사용
    final _HomeScreenState? homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀 바
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '김엘지 홈',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 12),
                    Icon(Icons.notifications_none),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 기기 연결 카드 (화면 중앙 정렬)
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: const Color(0xFFE2E2E2),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bluetooth, size: 60, color: Color(0xFF7FCEFF)),
                        const SizedBox(height: 12),
                        const Text(
                          '추가 기기를 연결해서 더 확장된 ThinQ 스마트 홈을\n만들어 보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            print('연결하기 버튼 눌림');
                            // 블루투스 연결 시도 여부 플래그 설정
                            if (homeScreenState != null) {
                              homeScreenState._wasBluetoothSettingsOpened = true;
                            }

                            // 앱 내에서 BLE 스캔 페이지로 이동
                            _navigateToBleScanPage(context);

                            // 기존 안드로이드 설정창 이동 로직은 주석 처리
                            /*
                            if (Platform.isAndroid) {
                              final intent = AndroidIntent(
                                action: 'android.settings.BLUETOOTH_SETTINGS',
                              );
                              try {
                                await intent.launch();
                                print('블루투스 설정 화면으로 이동 시도');
                              } catch (e) {
                                print('블루투스 설정 열기 실패: $e');
                              }
                            }
                            */
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7FCEFF),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('연결하기', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3D 홈뷰 카드
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: const Color(0xFFE2E2E2),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.home, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '3D 홈뷰로 우리집과 제품의 실시간 상태를\n한눈에 확인해보세요.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7FCEFF),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            ),
                            child: const Text('3D 홈뷰 만들기', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 즐겨찾는 제품 안내
            const Text('즐겨 찾는 제품', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const DottedBorderCard(),

            const SizedBox(height: 16),

            // ThinQ PLAY 배너
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7676),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'ThinQ PLAY\n',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const TextSpan(
                            text: '앱을 다운로드 하여 제품과 공간을 업그레이드 하세요.',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 스마트 루틴
            const Text('스마트 루틴', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFE2E2E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('루틴 알아보기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFE2E2E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('화면 편집'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class DottedBorderCard extends StatelessWidget {
  const DottedBorderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '제품을 추가해주세요. 제품을 즐겨 찾는 제품에 추가하면 홈 화면에서\n바로 사용할 수 있어요.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}

// 디바이스 화면 임시 구현
class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8, // 너비 대비 높이를 줄여 박스가 낮아지도록 조정
        children: const [
          DeviceTile(icon: Icons.kitchen, label: '냉장고'),
          DeviceTile(icon: Icons.soup_kitchen, label: '전기레인지'),
          DeviceTile(icon: Icons.tv, label: 'TV'),
          DeviceTile(icon: Icons.microwave, label: '광파오븐'),
          DeviceTile(icon: Icons.ac_unit, label: '에어컨'),
          DeviceTile(icon: Icons.table_chart, label: '테이스트Q'),
        ],
      ),
    );
  }
}

// 클릭 시 페이지 이동 및 제품 상세 페이지 오픈
class DeviceTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const DeviceTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // 냉장고, 테이스트Q는 기존 로직 유지
        if (label == '냉장고') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FridgeMainScreen(),
            ),
          );
        } else if (label == '테이스트Q') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TasteqMainScreen(),
            ),
          );
        }
        // 전기레인지, TV, 광파오븐, 에어컨은 상세페이지 URL로 Android에서 외부 브라우저로 명시적으로 열기
        else if (label == '전기레인지') {
          if (Platform.isAndroid) {
            final intent = AndroidIntent(
              action: 'action_view',
              data: 'https://www.lge.co.kr/electric-ranges/bey3srbl',
            );
            try {
              await intent.launch();
            } catch (e) {
              print('링크 열기 실패: $e');
            }
          }
        } else if (label == 'TV') {
          if (Platform.isAndroid) {
            final intent = AndroidIntent(
              action: 'action_view',
              data: 'https://www.lge.co.kr/tvs/86ut8300ena-wall',
            );
            try {
              await intent.launch();
            } catch (e) {
              print('링크 열기 실패: $e');
            }
          }
        } else if (label == '광파오븐') {
          if (Platform.isAndroid) {
            final intent = AndroidIntent(
              action: 'action_view',
              data: 'https://www.lge.co.kr/microwaves-and-ovens/mlj32ers',
            );
            try {
              await intent.launch();
            } catch (e) {
              print('링크 열기 실패: $e');
            }
          }
        } else if (label == '에어컨') {
          if (Platform.isAndroid) {
            final intent = AndroidIntent(
              action: 'action_view',
              data: 'https://www.lge.co.kr/air-conditioners/fq25fn9be2',
            );
            try {
              await intent.launch();
            } catch (e) {
              print('링크 열기 실패: $e');
            }
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF1F1F1),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}


// ========================= FridgeMainScreen 수정 ==========================

// (fridge_main_screen.dart에서 아래 코드가 있어야 합니다. body의 Column 시작 부분에 아래 위젯을 추가하세요.)

// 예시:
/*
body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 여기부터 추가
        const SizedBox(height: 16),
        Text('우리집 냉장고 배치', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          color: Color(0xFFE2E2E2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset('images/fridge_layout.png', height: 140, fit: BoxFit.cover),
                const SizedBox(height: 8),
                const Text('냉장고의 위치와 연결 상태를 확인하세요.', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 여기까지
        // ...기존 내용
      ]
    )
  )
)
*/

// ReportScreen: 전력량 모니터링 UI 임시 구현
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 최근 15일 날짜와 랜덤 전력 사용량 데이터 생성 (가장 최근 날짜가 맨 위)
    final now = DateTime.now();
    final random = Random();
    final usageData = List.generate(15, (index) {
      final date = now.subtract(Duration(days: index));
      final usage = (5 + random.nextDouble() * 5).toStringAsFixed(1); // 5.0~10.0
      return {
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'usage': usage
      };
    });
    // 최근 7일 데이터만 차트에 사용 (최신순)
    final chartData = usageData.take(7).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('전력량 모니터링', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4)],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 12,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= chartData.length) return const SizedBox();
                          final dateStr = chartData[index]['date']!.substring(5); // MM-DD
                          return Text(dateStr, style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10, overflow: TextOverflow.visible),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(chartData.length, (index) {
                    final usage = double.parse(chartData[index]['usage']!);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(toY: usage, width: 14, color: Colors.blueAccent),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('일간 소비량', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: usageData.length,
                itemBuilder: (context, index) {
                  final item = usageData[index];
                  return ReportTile(date: item['date']!, usage: '${item['usage']} kWh');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReportTile extends StatelessWidget {
  final String date;
  final String usage;

  const ReportTile({super.key, required this.date, required this.usage});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, size: 20),
      title: Text(date),
      trailing: Text(usage, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('LG ThinQ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.search),
              ],
            ),
            const SizedBox(height: 20),

            // 프로필 섹션
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('김엘지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 멤버십, Q리워드
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('멤버십'),
                  Text('0'),
                  Text('Q 리워드'),
                  Text('가입하기', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 제품 사용과 관리 타이틀
            const Text('제품 사용과 관리', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 12),

            // 항목 카드
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  MenuItem(icon: Icons.repeat, label: '스마트 루틴'),
                  Divider(height: 1),
                  MenuItem(icon: Icons.health_and_safety, label: '스마트 진단'),
                  Divider(height: 1),
                  MenuItem(icon: Icons.info_outline, label: '제품 정보와 보증'),
                  Divider(height: 1),
                  MenuItem(icon: Icons.menu_book, label: '제품 사용설명서'),
                  Divider(height: 1),
                  MenuItem(icon: Icons.lock, label: '소모품 정보'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('제품 업그레이드', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  MenuItem(icon: Icons.system_update, label: '소프트웨어 업데이트'),
                  Divider(height: 1),
                  MenuItem(icon: Icons.info_outline, label: '소프트웨어 정보'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}


// 커스텀 팝업 오버레이 함수와 위젯
void showCustomPopup(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100,
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: _AnimatedPopup(message: message),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

class _AnimatedPopup extends StatefulWidget {
  final String message;
  const _AnimatedPopup({Key? key, required this.message}) : super(key: key);

  @override
  State<_AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<_AnimatedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(minHeight: 36),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
  // BLE 스캔 및 연결 페이지로 이동하는 함수
  void _navigateToBleScanPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BleScanPage(), // 추후 생성될 BLE 스캔 페이지
      ),
    );
  }