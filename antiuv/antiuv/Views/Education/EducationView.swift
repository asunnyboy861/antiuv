import SwiftUI

struct EducationView: View {
    @State private var selectedCategory: EducationCategory = .uvIndex
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(EducationCategory.allCases) { category in
                        Text(category.title).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .frame(maxWidth: isIPad ? 600 : .infinity)
                
                ScrollView {
                    switch selectedCategory {
                    case .uvIndex:
                        UVIndexInfo()
                            .frame(maxWidth: isIPad ? 800 : .infinity)
                            .padding(.horizontal, isIPad ? 0 : 16)
                    case .skinCancer:
                        SkinCancerPrevention()
                            .frame(maxWidth: isIPad ? 800 : .infinity)
                            .padding(.horizontal, isIPad ? 0 : 16)
                    case .vitaminD:
                        VitaminDInfo()
                            .frame(maxWidth: isIPad ? 800 : .infinity)
                            .padding(.horizontal, isIPad ? 0 : 16)
                    case .sunscreen:
                        SunscreenGuide()
                            .frame(maxWidth: isIPad ? 800 : .infinity)
                            .padding(.horizontal, isIPad ? 0 : 16)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Sun Safety Education")
            .navigationBarTitleDisplayMode(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}

enum EducationCategory: String, CaseIterable, Identifiable {
    case uvIndex = "UV Index"
    case skinCancer = "Skin Cancer"
    case vitaminD = "Vitamin D"
    case sunscreen = "Sunscreen"
    
    var id: String { rawValue }
    var title: String { rawValue }
    var icon: String {
        switch self {
        case .uvIndex: return "sun.max"
        case .skinCancer: return "shield.slash"
        case .vitaminD: return "capsule"
        case .sunscreen: return "drop"
        }
    }
}

struct UVIndexInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoCard(
                title: "What is UV Index?",
                content: "The UV Index is an international standard measurement of the strength of ultraviolet (UV) radiation from the sun at a particular place and time. It helps you understand how quickly your skin can be damaged by the sun.",
                icon: "sun.max",
                color: .orange
            )
            
            InfoCard(
                title: "UV Index Scale",
                content: """
                • 0-2 (Low): Green - No protection needed
                • 3-5 (Moderate): Yellow - Seek shade during midday
                • 6-7 (High): Orange - Protection required
                • 8-10 (Very High): Red - Extra protection needed
                • 11+ (Extreme): Purple - Avoid being outside
                """,
                icon: "gauge",
                color: .blue
            )
            
            InfoCard(
                title: "When is UV Highest?",
                content: "UV radiation is strongest between 10am and 4pm, during summer months, at higher altitudes, and closer to the equator. Cloud cover doesn't always protect you - up to 80% of UV can penetrate clouds.",
                icon: "clock",
                color: .red
            )
        }
    }
}

struct SkinCancerPrevention: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoCard(
                title: "Skin Cancer Facts",
                content: "Skin cancer is the most common form of cancer worldwide. However, it's also one of the most preventable. Regular use of sunscreen can reduce your risk of developing squamous cell carcinoma by 40%.",
                icon: "heart",
                color: .red
            )
            
            InfoCard(
                title: "Prevention Tips",
                content: """
                ✓ Use broad-spectrum SPF 30+ daily
                ✓ Reapply every 2 hours
                ✓ Wear protective clothing
                ✓ Seek shade 10am-4pm
                ✓ Wear sunglasses and hat
                ✓ Avoid tanning beds
                ✓ Check your skin monthly
                """,
                icon: "checkmark.shield",
                color: .green
            )
            
            InfoCard(
                title: "Warning Signs",
                content: "See a dermatologist if you notice: new moles, changes in existing moles, sores that don't heal, or unusual skin growths. Early detection saves lives.",
                icon: "exclamationmark.triangle",
                color: .orange
            )
        }
    }
}

struct VitaminDInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoCard(
                title: "Vitamin D Benefits",
                content: "Vitamin D is essential for bone health, immune function, and mood regulation. Your body produces vitamin D when exposed to sunlight, but balance is key.",
                icon: "sun.horizon",
                color: .yellow
            )
            
            InfoCard(
                title: "Safe Sun Exposure",
                content: "For most people, 10-15 minutes of sun exposure 2-3 times per week is sufficient for vitamin D production. People with darker skin may need more time.",
                icon: "timer",
                color: .green
            )
            
            InfoCard(
                title: "Alternative Sources",
                content: """
                • Fatty fish (salmon, tuna, mackerel)
                • Fortified foods (milk, cereals)
                • Egg yolks
                • Vitamin D supplements
                """,
                icon: "fork.knife",
                color: .blue
            )
        }
    }
}

struct SunscreenGuide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoCard(
                title: "Choosing Sunscreen",
                content: "Look for: Broad-spectrum protection, SPF 30 or higher, water resistance. Chemical sunscreens absorb UV rays, while physical (mineral) sunscreens reflect them.",
                icon: "star",
                color: .orange
            )
            
            InfoCard(
                title: "Application Tips",
                content: """
                ✓ Apply 15 minutes before going outside
                ✓ Use 1 ounce (shot glass) for body
                ✓ Don't forget: ears, neck, lips, feet
                ✓ Reapply every 2 hours
                ✓ Reapply after swimming/sweating
                """,
                icon: "hand.raised",
                color: .blue
            )
            
            InfoCard(
                title: "SPF Explained",
                content: "SPF 30 blocks 97% of UVB rays, SPF 50 blocks 98%, and SPF 100 blocks 99%. No sunscreen blocks 100%, so reapplication is crucial regardless of SPF value.",
                icon: "percent",
                color: .purple
            )
        }
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    EducationView()
}
