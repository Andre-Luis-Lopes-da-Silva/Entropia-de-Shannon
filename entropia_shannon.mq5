//+------------------------------------------------------------------+
//| Cálculo da Entropia da Informação no Day Trade (MQL5)           |
//+------------------------------------------------------------------+
#property strict

// Parâmetros
input int Periodo = 50;  // Número de candles para calcular a entropia
input int Bins = 10;      // Número de bins para o histograma

// Função para calcular log-retornos
void CalcularLogRetornos(double &retornos[], double &closePrices[], int periodo) {  
    for (int i = 1; i < periodo; i++) {
        retornos[i - 1] = MathLog(closePrices[i]) - MathLog(closePrices[i + 1]);
    }
}

// Função para criar histograma e calcular probabilidades
void CalcularHistograma(double &retornos[], int tamanho, double &probabilidades[], int bins) {
    double minR = retornos[0], maxR = retornos[0];

    // Encontrar mínimo e máximo
    for (int i = 1; i < tamanho; i++) {
        if (retornos[i] < minR) minR = retornos[i];
        if (retornos[i] > maxR) maxR = retornos[i];
    }

    double intervalo = (maxR - minR) / bins;
    double histograma[10] = {0};  // Assume no máximo 10 bins

    // Contar ocorrências nos bins
    for (int i = 0; i < tamanho; i++) {
        int binIndex = (int)((retornos[i] - minR) / intervalo);
        if (binIndex >= bins) binIndex = bins - 1;
        histograma[binIndex]++;
    }

    // Normalizar para obter probabilidades
    for (int i = 0; i < bins; i++) {
        probabilidades[i] = histograma[i] / tamanho;
    }
}

// Função para calcular a entropia de Shannon
double CalcularEntropia(double &probabilidades[], int bins) {
    double entropia = 0.0;
    for (int i = 0; i < bins; i++) {
        if (probabilidades[i] > 0.0) {
            entropia -= probabilidades[i] * MathLog(probabilidades[i]) / MathLog(2.0);
        }
    }
    return entropia;
}

//+------------------------------------------------------------------+
//| Indicador de entropia                                           |
//+------------------------------------------------------------------+
void OnTick() {
    double closePrices[];  // Array para armazenar preços de fechamento
    double retornos[];  // Array dinâmico para armazenar os retornos
    double probabilidades[10];  // Array fixo para probabilidades

    // Redimensiona os arrays
    ArrayResize(retornos, Periodo - 1);
    ArrayResize(closePrices, Periodo + 1);

    // Copiar preços de fechamento do gráfico
    if (CopyClose(Symbol(), PERIOD_CURRENT, 0, Periodo + 1, closePrices) < Periodo + 1) {
        Print("Erro ao copiar preços de fechamento.");
        return;
    }

    // Calcular log-retornos
    CalcularLogRetornos(retornos, closePrices, Periodo);

    // Criar histograma e calcular probabilidades
    CalcularHistograma(retornos, Periodo - 1, probabilidades, Bins);

    // Calcular entropia
    double entropia = CalcularEntropia(probabilidades, Bins);

    // Exibir no log
    Print("Entropia do Mercado: ", entropia);

    // Adicionar ao gráfico (Opcional)
    Comment("Entropia: ", DoubleToString(entropia, 4));
}
