import 'package:budgetbook_2026/app/modules/chit_funds/bindings/edit_chit_funds_binding.dart';
import 'package:budgetbook_2026/app/modules/chit_funds/bindings/post_chit_funds_binding.dart';
import 'package:budgetbook_2026/app/modules/chit_funds/views/edit_chit_funds_view.dart';
import 'package:budgetbook_2026/app/modules/chit_funds/views/post_chit_funds_view.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/fill_profile_onentry.dart';
import '../modules/auth/views/login.dart';
import '../modules/auth/views/register.dart';
import '../modules/categories/bindings/categories_binding.dart';
import '../modules/categories/views/post_expense_category.dart';
import '../modules/categories/views/post_income_category.dart';
import '../modules/chit_funds/bindings/chit_funds_binding.dart';
import '../modules/chit_funds/views/chit_funds_view.dart';
import '../modules/credit_cards/bindings/credit_cards_binding.dart';
import '../modules/credit_cards/views/credit_cards_view.dart';
import '../modules/details/bindings/expense_details_binding.dart';
import '../modules/details/bindings/in_ex_details_binding.dart';
import '../modules/details/views/expense_details.dart';
import '../modules/details/views/income_details.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/incomeExpense/bindings/add_expense_binding.dart';
import '../modules/incomeExpense/bindings/add_income_binding.dart';
import '../modules/incomeExpense/bindings/expense_binding.dart';
import '../modules/incomeExpense/bindings/income_expense_binding.dart';
import '../modules/incomeExpense/views/add_expense.dart';
import '../modules/incomeExpense/views/add_income.dart';
import '../modules/incomeExpense/views/expense.dart';
import '../modules/incomeExpense/views/income.dart';
import '../modules/income_expense_edit/bindings/expense_edit_binding.dart';
import '../modules/income_expense_edit/bindings/income_expense_edit_binding.dart';
import '../modules/income_expense_edit/views/expense_edit_view.dart';
import '../modules/income_expense_edit/views/income_expense_edit_view.dart';
import '../modules/info/bindings/info_binding.dart';
import '../modules/info/views/notification.dart';
import '../modules/info/views/profile.dart';
import '../modules/lendBorrow/bindings/borrow_bindings.dart';
import '../modules/lendBorrow/bindings/lend_borrow_binding.dart';
import '../modules/lendBorrow/bindings/post_borrow_bindings.dart';
import '../modules/lendBorrow/bindings/post_lend_binding.dart';
import '../modules/lendBorrow/views/borrow.dart';
import '../modules/lendBorrow/views/lend.dart';
import '../modules/lendBorrow/views/post_borrow.dart';
import '../modules/lendBorrow/views/post_lend.dart';
import '../modules/lend_borrow_edit/bindings/borrow_edit_binding.dart';
import '../modules/lend_borrow_edit/bindings/lend_borrow_edit_binding.dart';
import '../modules/lend_borrow_edit/views/borrow_edit_view.dart';
import '../modules/lend_borrow_edit/views/lend_borrow_edit_view.dart';
import '../modules/loans/bindings/loans_binding.dart';
import '../modules/loans/bindings/post_loans_binding.dart';
import '../modules/loans/views/loans_view.dart';
import '../modules/loans/views/post_loan_view.dart';
import '../modules/onboard/bindings/onboard_binding.dart';
import '../modules/onboard/views/onboard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.ONBOARD,
      page: () => OnboardView(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: _Paths.INCOME_EXPENSE,
      page: () => IncomeExpenseView(),
      binding: IncomeExpenseBinding(),
    ),
    GetPage(
      name: _Paths.Expense,
      page: () => Expense(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: _Paths.IncomeDetails,
      page: () => IncomeDetails(),
      binding: IncomeExpDetailsController(),
      children: [
        GetPage(
          name: _Paths.IncomeDetails,
          page: () => IncomeDetails(),
          binding: IncomeExpenseBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.ExpenseDetails,
      page: () => ExpenseDetails(),
      binding: ExpenseDetailsBinding(),
    ),
    GetPage(name: _Paths.AUTH, page: () => AuthView(), binding: AuthBinding()),
    GetPage(
      name: _Paths.FillProfileOnentry,
      page: () => FillProfileOnentry(),
      binding: AuthBinding(),
    ),
    GetPage(name: _Paths.Login, page: () => Login(), binding: AuthBinding()),
    GetPage(name: _Paths.INFO, page: () => InfoView(), binding: InfoBinding()),
    GetPage(
      name: _Paths.Profile,
      page: () => Profile(),
      binding: InfoBinding(),
    ),
    GetPage(
      name: _Paths.LEND_BORROW,
      page: () => Lend(),
      binding: LendBorrowBinding(),
    ),
    GetPage(
      name: _Paths.ADD_INCOME,
      page: () => AddIncomeView(),
      binding: AddIncomeBinding(),
    ),
    GetPage(
      name: _Paths.ADD_EXPENSE,
      page: () => AddExpenseView(),
      binding: AddExpenseBinding(),
    ),
    GetPage(
      name: _Paths.PostIncomeCategory,
      page: () => PostIncomeCategory(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: _Paths.PostExpenseCategory,
      page: () => PostExpenseCategory(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: _Paths.INCOME_EXPENSE_EDIT,
      page: () => IncomeExpenseEditView(),
      binding: IncomeExpenseEditBinding(),
    ),
    GetPage(
      name: _Paths.ExpenseEditView,
      page: () => ExpenseEditView(),
      binding: ExpenseEditBinding(),
    ),
    GetPage(
      name: _Paths.LEND_BORROE_EDIT,
      page: () => LendBorrowEditView(),
      binding: LendBorrowEditBinding(),
    ),
    GetPage(
      name: _Paths.PostLend,
      page: () => PostLend(),
      binding: PostLendBinding(),
    ),
    GetPage(
      name: _Paths.Borrow,
      page: () => Borrow(),
      binding: BorrowBindings(),
    ),
    GetPage(
      name: _Paths.PostBorrow,
      page: () => PostBorrow(),
      binding: PostBorrowBindings(),
    ),
    GetPage(
      name: _Paths.BorrowEditView,
      page: () => BorrowEditView(),
      binding: BorrowEditBinding(),
    ),
    GetPage(
      name: _Paths.LOANS,
      page: () => const LoansView(),
      binding: LoansBinding(),
    ),
    GetPage(
      name: _Paths.PostLoanView,
      page: () => PostLoanView(),
      binding: PostLoansBinding(),
    ),
    GetPage(
      name: _Paths.CREDIT_CARDS,
      page: () => const CreditCardsView(),
      binding: CreditCardsBinding(),
    ),
    GetPage(
      name: _Paths.CHIT_FUNDS,
      page: () => const ChitFundsView(),
      binding: ChitFundsBinding(),
    ),
    GetPage(
      name: _Paths.PostChitFundsView,
      page: () => PostChitFundsView(),
      binding: PostChitFundsBinding(),
    ),
    GetPage(
        name: _Paths.EDIT_CHIT_FUNDS,
        page: () => EditChitFundsView(),
        binding: EditChitFundsBinding(),
      ),
  ];
}
