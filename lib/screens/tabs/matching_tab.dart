// ============================================================
// lib/screens/tabs/matching_tab.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/colors.dart';

class MatchingTab extends StatefulWidget {
  const MatchingTab({super.key});
  @override
  State<MatchingTab> createState() => _MatchingTabState();
}

class _MatchingTabState extends State<MatchingTab>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searchFocused = false;
  String _searchQuery = '';

  List<String> _recentSearches = ['강남역', '홍대입구', '잠실역', '판교역'];

  final TextEditingController _deptCtrl = TextEditingController();
  final TextEditingController _destCtrl = TextEditingController();
  final TextEditingController _kakaoCtrl = TextEditingController();
  int _maxPeople = 2;
  String? _selectedSeat;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _pinCreated = false;

  static const _seats = ['조수석', '왼쪽 창가', '가운데', '오른쪽 창가'];

  static const _pins = [
    {'hostId':'taxi_kim',  'dept':'강남역 2번출구','dest':'김포공항',   'time':'14:30','max':4,'cur':2},
    {'hostId':'seoul_lee', 'dept':'홍대입구역',    'dest':'인천공항 T1','time':'15:00','max':3,'cur':1},
    {'hostId':'rider_park','dept':'잠실역 8번',    'dest':'강남역',      'time':'14:45','max':4,'cur':3},
    {'hostId':'go_choi',   'dept':'신촌역',         'dest':'판교역',      'time':'16:00','max':2,'cur':0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _deptCtrl.dispose(); _destCtrl.dispose(); _kakaoCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPins {
    if (_searchQuery.isEmpty) return _pins;
    return _pins.where((p) =>
    (p['dept'] as String).contains(_searchQuery) ||
        (p['dest'] as String).contains(_searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildSearchTab(), _buildCreateTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text('매칭', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.secondary)),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.primary, width: 2.5),
            ),
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
            tabs: const [Tab(text: '🔍  검색'), Tab(text: '📍  핀 생성')],
          ),
        ],
      ),
    );
  }

  // 검색 탭
  Widget _buildSearchTab() {
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); setState(() => _searchFocused = false); },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Focus(
              onFocusChange: (f) => setState(() => _searchFocused = f),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '출발지 또는 목적지 검색...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.gray),
                      onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                      : null,
                  filled: true, fillColor: AppColors.bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchFocused && _searchQuery.isEmpty
                ? _buildRecentSearches()
                : _buildPinList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              const Text('최근 검색어', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _recentSearches = []),
                style: TextButton.styleFrom(foregroundColor: AppColors.gray),
                child: const Text('전체 삭제', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            itemBuilder: (_, i) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.history, color: AppColors.gray, size: 18),
              title: Text(_recentSearches[i], style: const TextStyle(fontSize: 14)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 16, color: AppColors.gray),
                onPressed: () => setState(() => _recentSearches.removeAt(i)),
              ),
              onTap: () {
                _searchCtrl.text = _recentSearches[i];
                setState(() { _searchQuery = _recentSearches[i]; _searchFocused = false; });
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinList() {
    final pins = _filteredPins;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
              _searchQuery.isEmpty ? '전체 ${pins.length}건' : '"$_searchQuery" ${pins.length}건',
              style: const TextStyle(fontSize: 12, color: AppColors.gray)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pins.length,
            itemBuilder: (_, i) => _buildSearchCard(pins[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(Map<String, dynamic> pin) {
    final isFull = (pin['cur'] as int) >= (pin['max'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bg, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.person, color: AppColors.gray, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${pin['hostId']}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(child: Text('${pin['dept']}',
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('→', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                        ),
                        Flexible(child: Text('${pin['dest']}',
                            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                            overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    const Text('출발', style: TextStyle(fontSize: 9, color: Colors.white70)),
                    Text('${pin['time']}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(pin['max'] as int, (j) => Container(
                width: 22, height: 22, margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: j < (pin['cur'] as int) ? AppColors.primary : AppColors.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: j < (pin['cur'] as int) ? AppColors.primary : AppColors.border),
                ),
                child: j < (pin['cur'] as int) ? const Icon(Icons.person, color: Colors.white, size: 13) : null,
              )),
              const SizedBox(width: 6),
              Text('${pin['cur']}/${pin['max']}명', style: const TextStyle(fontSize: 11, color: AppColors.gray)),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFull ? AppColors.gray : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: isFull ? null : () {},
                  child: Text(isFull ? '마감' : '참여하기',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 핀 생성 탭
  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pinCreated)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Text('✅', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text('핀이 생성되었습니다!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.person, color: AppColors.gray, size: 26),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('@my_username',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(children: [
                      _tag('인증됨 ✓'),
                      const SizedBox(width: 4),
                      _tag('⭐ 4.8', color: AppColors.accent, bg: const Color(0xFFFFF8E6)),
                    ]),
                  ],
                ),
              ],
            ),
          ),

          _label('📍 출발지'), const SizedBox(height: 6),
          _textField(_deptCtrl, '예: 강남역 2번 출구'),
          const SizedBox(height: 14),

          _label('🏁 목적지'), const SizedBox(height: 6),
          _textField(_destCtrl, '예: 김포공항 국내선'),
          const SizedBox(height: 14),

          // 출발 시간 피커
          _label('🕐 출발 시간'), const SizedBox(height: 6),
          GestureDetector(
            onTap: _showTimePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.gray, size: 20),
                  const SizedBox(width: 10),
                  Text(_selectedTime.format(context),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.gray),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 모집 인원
          _label('👥 모집 인원 (최대 4명)'), const SizedBox(height: 8),
          Row(
            children: [2, 3, 4].map((n) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _maxPeople = n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: _maxPeople == n ? AppColors.primary : AppColors.bg,
                      border: Border.all(color: _maxPeople == n ? AppColors.primary : AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$n명', textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                            color: _maxPeople == n ? Colors.white : AppColors.gray)),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // 좌석 선택
          _label('💺 좌석 선택'), const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _seats.map((seat) => Expanded( // 좌석 버튼들 Row 안에서 동일한 너비로 배치
              child: GestureDetector(
                onTap: () => setState(() => _selectedSeat = seat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150), // 애니메이션 진행 시간
                  height: 45,  // 버튼 높이(세로) 길이 고정
                  margin: const EdgeInsets.symmetric(horizontal: 6), // 버튼 사이 여백
                  decoration: BoxDecoration(
                    color: _selectedSeat == seat ? AppColors.primaryLight : AppColors.bg,
                    border: Border.all(
                      color: _selectedSeat == seat ? AppColors.primary : AppColors.border,
                      width: _selectedSeat == seat ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row( // 버튼 내부 아이콘, 텍스트 정렬
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_seat, size: 15,
                          color: _selectedSeat == seat ? AppColors.primary : AppColors.gray),
                      const SizedBox(width: 5),
                      Text(seat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedSeat == seat ? AppColors.primary : AppColors.gray,
                          )),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          _label('💛 카카오페이 링크 (선택)'), const SizedBox(height: 6),
          TextField(
            controller: _kakaoCtrl,
            decoration: InputDecoration(
              hintText: 'https://qr.kakaopay.com/...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.gray),
              filled: true, fillColor: const Color(0xFFFFFDE7),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _handleCreate,
              child: const Text('📍 핀 생성하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        TimeOfDay tempTime = _selectedTime;
        return StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
              const Text('출발 시간 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: DateTime(2024, 1, 1, _selectedTime.hour, _selectedTime.minute),
                  onDateTimeChanged: (dt) {
                    setModalState(() => tempTime = TimeOfDay(hour: dt.hour, minute: dt.minute));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () { setState(() => _selectedTime = tempTime); Navigator.pop(context); },
                    child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCreate() {
    if (_deptCtrl.text.isEmpty || _destCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('출발지와 목적지를 입력해주세요.'),
        backgroundColor: AppColors.red,
      ));
      return;
    }
    setState(() => _pinCreated = true);
    _deptCtrl.clear(); _destCtrl.clear(); _kakaoCtrl.clear();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _pinCreated = false);
    });
  }

  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary));

  Widget _textField(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );

  Widget _tag(String text, {Color color = AppColors.primary, Color bg = AppColors.primaryLight}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
        child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      );
}