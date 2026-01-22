import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/domain/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_state.dart';

class AdminAvatarBloc extends Bloc<AdminAvatarEvent, AdminAvatarState> {
  final AdminRepository repo;

  AdminAvatarBloc(this.repo) : super(AvatarInitial()) {
    // 1. LOAD DATA
    on<LoadAvatarsEvent>((event, emit) async {
      emit(AvatarLoading());
      try {
        final data = await repo.fetchAvatars();
        // Saat awal load, filtered = all
        emit(AvatarLoaded(allAvatars: data, filteredAvatars: data));
      } catch (e) {
        emit(AvatarError(e.toString()));
      }
    });

    // 2. ADD AVATAR
    on<AddAvatarEvent>((event, emit) async {
      try {
        await repo.createAvatar(
          event.name,
          event.url,
          event.price,
          event.rarity,
          file: event.file,
        );
        add(LoadAvatarsEvent());
      } catch (e) {
        emit(AvatarError("Gagal tambah: $e"));
        add(LoadAvatarsEvent());
      }
    });

    // 3. EDIT AVATAR
    on<EditAvatarEvent>((event, emit) async {
      try {
        await repo.updateAvatar(
          event.id,
          event.name,
          event.url,
          event.price,
          event.rarity,
          file: event.file,
        );
        add(LoadAvatarsEvent());
      } catch (e) {
        emit(AvatarError("Gagal edit: $e"));
        add(LoadAvatarsEvent());
      }
    });

    // 4. TOGGLE STATUS
    on<ToggleAvatarEvent>((event, emit) async {
      try {
        await repo.toggleAvatarStatus(event.id);
        add(LoadAvatarsEvent());
      } catch (e) {
        emit(AvatarError("Gagal update status: $e"));
        add(LoadAvatarsEvent());
      }
    });

    // 5. [BARU] FILTER & SORT AVATAR
    on<FilterAvatarsEvent>((event, emit) {
      if (state is AvatarLoaded) {
        final currentState = state as AvatarLoaded;
        List<AvatarModel> results = List.from(currentState.allAvatars);

        // A. Filter Rarity
        if (event.rarity != 'All') {
          results = results
              .where(
                (a) => a.rarity.toLowerCase() == event.rarity.toLowerCase(),
              )
              .toList();
        }

        // B. Sort Price
        if (event.sortBy == 'Lowest Price') {
          results.sort((a, b) => a.price.compareTo(b.price));
        } else if (event.sortBy == 'Highest Price') {
          results.sort((a, b) => b.price.compareTo(a.price));
        }

        // Emit state baru dengan list terfilter, tapi allAvatars tetap utuh
        emit(
          AvatarLoaded(
            allAvatars: currentState.allAvatars,
            filteredAvatars: results,
          ),
        );
      }
    });
  }
}
