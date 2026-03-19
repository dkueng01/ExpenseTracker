import SwiftUI

struct EditExpenseView: View {
    let expense: Expense

    var body: some View {
        ExpenseEditorView(mode: .edit(expense))
    }
}
