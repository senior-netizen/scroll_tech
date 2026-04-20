import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';
import '../../domain/models/shop_info.dart';

class ShopInfoEvent extends Equatable {
  const ShopInfoEvent();
  @override
  List<Object?> get props => [];
}

class ShopInfoLoadRequested extends ShopInfoEvent {
  const ShopInfoLoadRequested();
}

class ShopInfoState extends Equatable {
  const ShopInfoState({this.loading = false, this.info, this.error});
  final bool loading;
  final ShopInfo? info;
  final String? error;

  ShopInfoState copyWith({bool? loading, ShopInfo? info, String? error}) =>
      ShopInfoState(loading: loading ?? this.loading, info: info ?? this.info, error: error);

  @override
  List<Object?> get props => [loading, info, error];
}

class ShopInfoBloc extends Bloc<ShopInfoEvent, ShopInfoState> {
  ShopInfoBloc() : super(const ShopInfoState()) {
    on<ShopInfoLoadRequested>(_load);
  }

  Future<void> _load(ShopInfoLoadRequested event, Emitter<ShopInfoState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final info = await AppDependencies.getShopInfoUseCase();
      emit(state.copyWith(loading: false, info: info));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Could not load shop info'));
    }
  }
}

class ShopInfoScreen extends StatelessWidget {
  const ShopInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShopInfoBloc()..add(const ShopInfoLoadRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Shop Info')),
        body: BlocBuilder<ShopInfoBloc, ShopInfoState>(
          builder: (context, state) {
            if (state.loading) return const Center(child: CircularProgressIndicator());
            final info = state.info;
            if (info == null) return Center(child: Text(state.error ?? 'No data'));
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ListTile(title: Text(info.name), subtitle: Text(info.address)),
                ListTile(title: const Text('Hours'), subtitle: Text(info.hours)),
                ListTile(title: const Text('Map'), subtitle: Text(info.mapUrl)),
                ListTile(title: const Text('Directions'), subtitle: Text(info.directionsUrl)),
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white10),
                  alignment: Alignment.center,
                  child: const Text('Embedded map placeholder (optimized lightweight view)'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
