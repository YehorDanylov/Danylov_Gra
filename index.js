const express = require("express");
const { exec } = require("child_process");
const app = express();
const port = 8000;

app.use(express.static('public'));

// Обробка запиту на отримання лабіринту
app.get("/maze", (req, res) => {
    exec(`swipl -s labyrinth.pl -g export_maze -t halt`, (error, stdout, stderr) => {

    // Виведення помилок
    if (error) {
      console.error(`❌ Помилка при виконанні Prolog: ${error.message}`);
      return res.status(500).send('Error');
    }
    if (stderr) {
      console.error(`⚠️ stderr: ${stderr}`);
      return res.status(500).send('Error');
    }

    // Виведення результату Prolog
    console.log("Результат Prolog:");
    console.log(stdout);  

    try {
      // Витягнення тільки JSON-частини з результату
      const result = stdout.trim();
      const jsonStart = result.indexOf('{');
      const jsonEnd = result.lastIndexOf('}');
      
    
      if (jsonStart === -1 || jsonEnd === -1) {
        console.error("❌ Результат Prolog не містить валідного JSON.");
        return res.status(500).send('Error');
      }

      const jsonString = result.slice(jsonStart, jsonEnd + 1);
      
      // Парсинг JSON
      const parsedResult = JSON.parse(jsonString);
      console.log("Парсинг успішний, JSON результат:", parsedResult);  // Перевірка парсингу

      
      console.log("Виправлений результат:", parsedResult);

      res.json(parsedResult);  // Відправка JSON у відповідь
    } catch (err) {
      console.error(`❌ Не вдалося обробити результат: ${err.message}`);
      return res.status(500).send('Error');
    }
  });
});

// Запуск сервера
app.listen(port, () => {
  console.log(`Server запущено на http://localhost:${port}`);
});