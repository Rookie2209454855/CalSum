import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_service.dart';
import '../services/exercise_service.dart';
import 'food_page.dart';
import 'exercise_page.dart';
import 'summary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const FoodPage(),
    const ExercisePage(),
    const SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      appBar: isDesktop ? null : AppBar(
        title: const Text('CalSum'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: 实现退出登录逻辑
            },
          ),
        ],
      ),
      body: isDesktop ? _buildDesktopLayout() : _pages[_currentIndex],
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: '食物',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: '运动',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 || _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                // TODO: 根据当前页面打开对应的添加表单
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 侧边栏导航
        Container(
          width: 240,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              // 应用标题
              Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CalSum',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 导航菜单
              Expanded(
                child: ListView(
                  children: [
                    _buildDesktopNavItem(Icons.dashboard, '主页', 0),
                    _buildDesktopNavItem(Icons.restaurant, '食物记录', 1),
                    _buildDesktopNavItem(Icons.fitness_center, '运动记录', 2),
                    _buildDesktopNavItem(Icons.bar_chart, '数据统计', 3),
                    const Divider(color: Colors.white54),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.white),
                      title: Text('退出登录', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        // TODO: 实现退出登录逻辑
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 主内容区域
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: _pages[_currentIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNavItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _currentIndex == index,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () => setState(() => _currentIndex = index),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日概览卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日概览',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        '摄入热量',
                        '0 kcal',
                        Icons.restaurant,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        '消耗热量',
                        '0 kcal',
                        Icons.fitness_center,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 快速操作区域
          Text(
            '快速操作',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  '添加食物',
                  Icons.restaurant,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodPage()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionCard(
                  context,
                  '添加运动',
                  Icons.fitness_center,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExercisePage()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 最近记录
          Text(
            '最近记录',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildRecentItem('早餐', '面包 200g', '300 kcal', Icons.restaurant),
                _buildRecentItem('运动', '跑步 30分钟', '250 kcal', Icons.fitness_center),
                _buildRecentItem('午餐', '米饭 150g', '200 kcal', Icons.restaurant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItem(String type, String name, String calories, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(name),
        subtitle: Text(type),
        trailing: Text(calories),
      ),
    );
  }
}