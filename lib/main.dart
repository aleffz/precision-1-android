import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const PrecisionApp());

const bg = Color(0xFF070707);
const panel = Color(0xFF151010);
const neon = Color(0xFFFF303B);

class PrecisionApp extends StatelessWidget {
  const PrecisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Precision 1.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: neon,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  double geral = 95, redDot = 90, mira2x = 85, mira4x = 80, awm = 50;
  String profile = 'Equilibrado';
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      geral = p.getDouble('geral') ?? 95;
      redDot = p.getDouble('redDot') ?? 90;
      mira2x = p.getDouble('mira2x') ?? 85;
      mira4x = p.getDouble('mira4x') ?? 80;
      awm = p.getDouble('awm') ?? 50;
      profile = p.getString('profile') ?? 'Equilibrado';
      loaded = true;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('geral', geral);
    await p.setDouble('redDot', redDot);
    await p.setDouble('mira2x', mira2x);
    await p.setDouble('mira4x', mira4x);
    await p.setDouble('awm', awm);
    await p.setString('profile', profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo neste aparelho.')),
    );
  }

  Future<void> _copySettings() async {
    final text = '''
PRECISION 1.0
Perfil: $profile
Geral: ${geral.round()}
Red Dot: ${redDot.round()}
Mira 2x: ${mira2x.round()}
Mira 4x: ${mira4x.round()}
AWM: ${awm.round()}

Ajustes de referência para configurar manualmente no jogo.
''';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações copiadas!')),
    );
  }

  void _preset(String name) {
    setState(() {
      profile = name;
      if (name == 'Precisão') {
        geral = 88; redDot = 82; mira2x = 76; mira4x = 68; awm = 42;
      } else if (name == 'Rápido') {
        geral = 150; redDot = 140; mira2x = 125; mira4x = 110; awm = 75;
      } else {
        geral = 95; redDot = 90; mira2x = 85; mira4x = 80; awm = 50;
      }
    });
    _save();
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 7),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neon.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(value.round().toString(),
                style: const TextStyle(color: neon, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value.clamp(0, 200),
            min: 0,
            max: 200,
            divisions: 200,
            activeColor: neon,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _button(String text, IconData icon, VoidCallback action) {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: action,
        icon: Icon(icon),
        label: Text(text),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8E101B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }

  Widget _precisionPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('PRECISION 1.0',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: neon)),
      const SizedBox(height: 5),
      const Text('Ajuste seus controles e salve seu perfil.',
        style: TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PERFIL DE CONFIGURAÇÃO',
            style: TextStyle(color: neon, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            for (final name in ['Equilibrado', 'Precisão', 'Rápido'])
              ChoiceChip(
                label: Text(name),
                selected: profile == name,
                selectedColor: neon.withOpacity(.25),
                onSelected: (_) => _preset(name),
              ),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      _slider('Sensibilidade geral', geral, (v) => setState(() => geral = v)),
      _slider('Red Dot', redDot, (v) => setState(() => redDot = v)),
      _slider('Mira 2x', mira2x, (v) => setState(() => mira2x = v)),
      _slider('Mira 4x', mira4x, (v) => setState(() => mira4x = v)),
      _slider('AWM / Sniper', awm, (v) => setState(() => awm = v)),
      _button('SALVAR PERFIL', Icons.save, _save),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: _copySettings,
        icon: const Icon(Icons.copy),
        label: const Text('COPIAR CONFIGURAÇÕES'),
        style: OutlinedButton.styleFrom(foregroundColor: neon,
          side: const BorderSide(color: neon), minimumSize: const Size.fromHeight(50)),
      ),
      const SizedBox(height: 10),
      const Text('Os valores são sugestões de referência. Ajuste-os dentro das configurações do jogo.',
        style: TextStyle(color: Colors.white54, fontSize: 12)),
    ],
  );

  Widget _boostPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text('BOOST / OTIMIZAÇÃO',
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: neon)),
      const SizedBox(height: 8),
      const Text('Checklist para melhorar a estabilidade do aparelho sem alterar o jogo.',
        style: TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      _tip(Icons.battery_charging_full, 'Bateria',
        'Antes de jogar, deixe a bateria carregada e evite jogar enquanto o aparelho estiver muito quente.'),
      _tip(Icons.cleaning_services, 'Aplicativos em segundo plano',
        'Feche aplicativos que você não está usando para liberar recursos.'),
      _tip(Icons.wifi, 'Conexão',
        'Prefira uma conexão estável e evite downloads durante a partida.'),
      _tip(Icons.thermostat, 'Temperatura',
        'Se o aparelho esquentar, faça uma pausa para ele esfriar.'),
      _tip(Icons.settings, 'Gráficos do jogo',
        'Se houver travamentos, experimente reduzir os gráficos nas opções oficiais do Free Fire.'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: neon.withOpacity(.35))),
        child: const Text(
          'Este painel não injeta arquivos, não altera a memória do Free Fire e não promete aumentar FPS ou precisão automaticamente.',
          style: TextStyle(color: Colors.white70, height: 1.4)),
      ),
    ],
  );

  Widget _tip(IconData icon, String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: neon.withOpacity(.2))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: neon, size: 26),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: Colors.white60, height: 1.35)),
      ])),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    if (!loaded) return const Scaffold(body: Center(
      child: CircularProgressIndicator(color: neon)));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF100808),
        title: const Text('PRECISION 1.0',
          style: TextStyle(color: neon, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [IconButton(
          tooltip: 'Salvar',
          onPressed: _save,
          icon: const Icon(Icons.save_outlined, color: neon))],
      ),
      body: IndexedStack(index: tab, children: [_precisionPage(), _boostPage()]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF100808),
        indicatorColor: neon.withOpacity(.2),
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.gps_fixed), label: 'Precision'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Boost'),
        ],
      ),
    );
  }
}
