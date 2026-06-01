import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/grupo_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'horarios_screen.dart';

class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});

  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _mostrarDialogAgregarGrupo() {
    final nombreController = TextEditingController();
    final semestreController = TextEditingController();
    String turnoSeleccionado = 'Matutino';
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.grisOscuro : AppColors.blanco,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textoGris.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Agregar grupo',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Nombre del grupo (ej: 6°A)',
                    controller: nombreController,
                    prefixIcon: Icons.group_outlined,
                    validator: (v) => v == null || v.isEmpty
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Semestre (ej: 6)',
                    controller: semestreController,
                    prefixIcon: Icons.school_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty
                        ? 'El semestre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Turno',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.textoGris,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Matutino', 'Vespertino'].map((turno) {
                      final isSelected = turnoSeleccionado == turno;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setModalState(() => turnoSeleccionado = turno),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.vinoClaro
                                      : AppColors.vino)
                                  : (isDark
                                      ? AppColors.grisMedio
                                      : AppColors.grisClaro),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                turno,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.blanco
                                      : AppColors.textoGris,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    texto: 'Agregar grupo',
                    icono: Icons.add,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final docRef =
                          _db.collection(AppConstants.colGrupos).doc();
                      final grupo = GrupoModel(
                        id: docRef.id,
                        nombre: nombreController.text.trim(),
                        semestre: semestreController.text.trim(),
                        turno: turnoSeleccionado,
                        horarios: GrupoModel.diasSemana
                            .map((dia) => HorarioDia(
                                  dia: dia,
                                  horaEntrada: '07:00',
                                  horaSalida: '13:30',
                                ))
                            .toList(),
                        createdAt: DateTime.now(),
                      );
                      await docRef.set(grupo.toMap());
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _eliminarGrupo(String grupoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Eliminar grupo',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de eliminar este grupo?',
          style: GoogleFonts.montserrat(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(color: AppColors.textoGris),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.montserrat(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.collection(AppConstants.colGrupos).doc(grupoId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.negro : AppColors.grisClaro,
      appBar: AppBar(
        title: const Text('Grupos'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogAgregarGrupo,
        backgroundColor: isDark ? AppColors.vinoClaro : AppColors.vino,
        icon: const Icon(Icons.add, color: AppColors.blanco),
        label: Text(
          'Agregar grupo',
          style: GoogleFonts.montserrat(
            color: AppColors.blanco,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection(AppConstants.colGrupos)
            .orderBy('nombre')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: AppColors.textoGris.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay grupos registrados',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: AppColors.textoGris,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca el botón para agregar uno',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppColors.textoGris.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          final grupos = snapshot.data!.docs
              .map((d) => GrupoModel.fromMap(d.data() as Map<String, dynamic>))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: grupos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final grupo = grupos[index];
              return _GrupoCard(
                grupo: grupo,
                onVerHorarios: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HorariosScreen(grupo: grupo),
                  ),
                ),
                onEliminar: () => _eliminarGrupo(grupo.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _GrupoCard extends StatelessWidget {
  final GrupoModel grupo;
  final VoidCallback onVerHorarios;
  final VoidCallback onEliminar;

  const _GrupoCard({
    required this.grupo,
    required this.onVerHorarios,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.grisOscuro : AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.negro.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.vinoClaro : AppColors.vino)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              grupo.nombre,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.vinoClaro : AppColors.vino,
              ),
            ),
          ),
        ),
        title: Text(
          'Grupo ${grupo.nombre}',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Semestre ${grupo.semestre} — ${grupo.turno}',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: AppColors.textoGris,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.schedule_outlined,
                color: isDark ? AppColors.vinoClaro : AppColors.vino,
              ),
              tooltip: 'Ver horarios',
              onPressed: onVerHorarios,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
              ),
              tooltip: 'Eliminar',
              onPressed: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}
