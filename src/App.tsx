import { Header } from "./components/header";
import { HeroSection } from "./components/hero-section";
import { ProductsSection } from "./components/products-section";
import { AdvantagesSection } from "./components/advantages-section";
import { CalculatorSection } from "./components/calculator-section";
import { ProjectsSection } from "./components/projects-section";
import { CatalogSection } from "./components/catalog-section";
import { Footer } from "./components/footer";

export default function App() {
  return (
    <div className="min-h-screen bg-white">
      <Header />
      <main>
        <HeroSection />
        <ProductsSection />
        <AdvantagesSection />
        <CalculatorSection />
        <ProjectsSection />
        <CatalogSection />
      </main>
      <Footer />
    </div>
  );
}