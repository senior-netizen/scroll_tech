import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/dependencies.dart';

class InquiryEvent extends Equatable {
  const InquiryEvent();
  @override
  List<Object?> get props => [];
}

class InquirySubmitted extends InquiryEvent {
  const InquirySubmitted({required this.contextText, required this.phone});
  final String contextText;
  final String phone;
  @override
  List<Object?> get props => [contextText, phone];
}

class InquiryState extends Equatable {
  const InquiryState({this.loading = false, this.link, this.error});
  final bool loading;
  final String? link;
  final String? error;

  InquiryState copyWith({bool? loading, String? link, String? error}) =>
      InquiryState(loading: loading ?? this.loading, link: link ?? this.link, error: error);

  @override
  List<Object?> get props => [loading, link, error];
}

class InquiryBloc extends Bloc<InquiryEvent, InquiryState> {
  InquiryBloc() : super(const InquiryState()) {
    on<InquirySubmitted>(_submit);
  }

  Future<void> _submit(InquirySubmitted event, Emitter<InquiryState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final link = await AppDependencies.buildInquiryLinkUseCase(context: event.contextText, phone: event.phone);
      emit(state.copyWith(loading: false, link: link));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Failed to generate WhatsApp link'));
    }
  }
}

class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key, required this.contextText});
  final String contextText;

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  late final TextEditingController _context;
  final _phone = TextEditingController(text: '15551234567');

  @override
  void initState() {
    super.initState();
    _context = TextEditingController(text: widget.contextText);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InquiryBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Inquiry Form')),
        body: BlocBuilder<InquiryBloc, InquiryState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                TextField(controller: _context, decoration: const InputDecoration(labelText: 'Context')),
                TextField(controller: _phone, decoration: const InputDecoration(labelText: 'WhatsApp Number')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => context.read<InquiryBloc>().add(
                            InquirySubmitted(contextText: _context.text, phone: _phone.text),
                          ),
                  child: const Text('Generate WhatsApp Deep Link'),
                ),
                if (state.link != null) SelectableText(state.link!),
                if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            );
          },
        ),
      ),
    );
  }
}
