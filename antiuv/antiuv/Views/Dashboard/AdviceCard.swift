import SwiftUI

struct AdviceCard: View {
    let advice: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Sun Safety Advice", systemImage: "info.circle")
                .font(.headline)
                .accessibilityLabel("Sun Safety Advice")
            
            Text(advice)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
                .accessibilityLabel(advice)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AdviceCard(advice: "Protection required! Wear protective clothing, hat, sunglasses, and SPF 50+ sunscreen. Limit sun exposure between 10am-4pm.")
        .padding()
}
