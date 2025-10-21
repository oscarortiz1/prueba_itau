import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_payload.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({
    required GetTransactions getTransactions,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  })  : _getTransactions = getTransactions,
        _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        super(const TransactionsState()) {
    on<TransactionsLoaded>(_onLoaded);
    on<TransactionCreateRequested>(_onCreateRequested);
    on<TransactionUpdateRequested>(_onUpdateRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
  }

  final GetTransactions _getTransactions;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  Future<void> _onLoaded(TransactionsLoaded event, Emitter<TransactionsState> emit) async {
  emit(state.copyWith(status: TransactionsStatus.loading, clearError: true));

    try {
      final transactions = await _getTransactions();
      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: _sorted(transactions),
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(state.copyWith(status: TransactionsStatus.failure, errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(status: TransactionsStatus.failure, errorMessage: 'No se pudieron cargar las transacciones.'));
    }
  }

  Future<void> _onCreateRequested(
    TransactionCreateRequested event,
    Emitter<TransactionsState> emit,
  ) async {
  emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      final transaction = await _createTransaction(event.payload);
      final updatedList = List<Transaction>.from(state.transactions)..add(transaction);
      emit(
        state.copyWith(
          isProcessing: false,
          transactions: _sorted(updatedList),
          status: TransactionsStatus.success,
        ),
      );
    } on AppException catch (error) {
      emit(state.copyWith(isProcessing: false, errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(isProcessing: false, errorMessage: 'No se pudo crear la transaccion.'));
    }
  }

  Future<void> _onUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionsState> emit,
  ) async {
  emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      final transaction = await _updateTransaction(event.id, event.payload);
      final updatedList = state.transactions.map((item) => item.id == transaction.id ? transaction : item).toList();
      emit(
        state.copyWith(
          isProcessing: false,
          transactions: _sorted(updatedList),
          status: TransactionsStatus.success,
        ),
      );
    } on AppException catch (error) {
      emit(state.copyWith(isProcessing: false, errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(isProcessing: false, errorMessage: 'No se pudo actualizar la transaccion.'));
    }
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionsState> emit,
  ) async {
  emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      await _deleteTransaction(event.id);
      final updatedList = state.transactions.where((item) => item.id != event.id).toList();
      emit(
        state.copyWith(
          isProcessing: false,
          transactions: updatedList,
          status: TransactionsStatus.success,
        ),
      );
    } on AppException catch (error) {
      emit(state.copyWith(isProcessing: false, errorMessage: error.message));
    } catch (_) {
      emit(state.copyWith(isProcessing: false, errorMessage: 'No se pudo eliminar la transaccion.'));
    }
  }

  List<Transaction> _sorted(List<Transaction> transactions) {
    final list = List<Transaction>.from(transactions);
    list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return list;
  }
}
