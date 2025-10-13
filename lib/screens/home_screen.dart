// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/screens/settings_screen.dart'; 
import 'package:timeismoney/widgets/footer_bar.dart';
import 'package:timeismoney/widgets/timer_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MultiTimerController>();
    final activeTimers = controller.activeTimers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Is Money'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Réglages et Taux',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: activeTimers.isEmpty
                ? _buildNoTimersView()
                : activeTimers.length == 1
                    ? _buildSingleTimerView(controller, activeTimers[0], 0)
                    : _buildMultiTimerView(controller, activeTimers),
          ),
          const FooterBar(creatorName: 'XR'),
        ],
      ),
    );
  }

  Widget _buildNoTimersView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Aucun timer actif',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Activez un timer dans les réglages pour commencer',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTimerView(MultiTimerController controller, timer, int index) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: TimerDisplay(
            timer: timer,
            timerIndex: index,
            onStart: () => controller.startTimer(index),
            onStop: () => controller.stopTimer(index),
            onReset: () => controller.resetTimer(index),
            onTimeEdited: () => controller.editTimerTime(index),
            isCompact: false,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiTimerView(MultiTimerController controller, List activeTimers) {
    return Builder(
      builder: (context) => Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Expanded(
                child: SingleChildScrollView(
                  child: TimerDisplay(
                    timer: activeTimers[0],
                    timerIndex: controller.timers.indexOf(activeTimers[0]),
                    onStart: () => controller.startTimer(controller.timers.indexOf(activeTimers[0])),
                    onStop: () => controller.stopTimer(controller.timers.indexOf(activeTimers[0])),
                    onReset: () => controller.resetTimer(controller.timers.indexOf(activeTimers[0])),
                    onTimeEdited: () => controller.editTimerTime(controller.timers.indexOf(activeTimers[0])),
                    isCompact: true,
                  ),
                ),
              ),
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Démarrer tous',
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () => controller.startAllTimers(),
                        iconSize: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Tooltip(
                      message: 'Arrêter tous',
                      child: IconButton(
                        icon: const Icon(Icons.pause, color: Colors.red),
                        onPressed: () => controller.stopAllTimers(),
                        iconSize: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Tooltip(
                      message: 'Réinitialiser tous',
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.orange),
                        onPressed: () => controller.resetAllTimers(),
                        iconSize: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24, thickness: 1),
                    const SizedBox(height: 20),
                    Tooltip(
                      message: 'Synchroniser les timers',
                      child: IconButton(
                        icon: const Icon(Icons.sync, color: Colors.blue),
                        onPressed: () {
                          controller.synchronizeTimers();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Timers synchronisés !'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        iconSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeTimers.length > 1)
                Expanded(
                  child: SingleChildScrollView(
                    child: TimerDisplay(
                      timer: activeTimers[1],
                      timerIndex: controller.timers.indexOf(activeTimers[1]),
                      onStart: () => controller.startTimer(controller.timers.indexOf(activeTimers[1])),
                      onStop: () => controller.stopTimer(controller.timers.indexOf(activeTimers[1])),
                      onReset: () => controller.resetTimer(controller.timers.indexOf(activeTimers[1])),
                      onTimeEdited: () => controller.editTimerTime(controller.timers.indexOf(activeTimers[1])),
                      isCompact: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
