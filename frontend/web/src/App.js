import { BrowserRouter as Router, Routes, Route} from 'react-router-dom';
import Main from './1main/main.jsx';
import AIService from './2aiservice/aiservice.jsx';
import UserManaging from './3manage/manage.jsx';
import Login from './4login/login.jsx';
import AppDownload from './5download/download.jsx';
import Operate from './3operate/operate.jsx';

function App() {
  return (
    <Router>
      <div className="App">
        <Routes>
          <Route path="/" element={<Main />} />
          <Route path="/aiservice" element={<AIService />} />
          <Route path="/manage" element={<UserManaging />} />
          <Route path="/operate" element={<Operate />} />
          <Route path="/login" element={<Login />} />
          <Route path="/download" element={<AppDownload />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;