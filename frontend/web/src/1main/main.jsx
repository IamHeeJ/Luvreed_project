import main1 from '../img/main1.png';
import main2 from '../img/main2.png';
import main3 from '../img/main3.png';
import main4 from '../img/main4.png';
import main5 from '../img/main5.png';
import './main.css';
import Header from '../0header/header';

export default function Main() {
  return (
    <div className="Main">
      <Header/>
      <main className="main-container">
        <div className="main1div">
          <img src={main1} alt="main1"/>
        </div>
        <div className="main2div">
          <img src={main2} alt="main2"/>
        </div>
        <div className="main3div">
          <img src={main3} alt="main3"/>
        </div>
        <div className="main4div">
          <img src={main4} alt="main4"/>
        </div>
        <div className="main5div">
          <img src={main5} alt="main5"/>
        </div>
      </main>
    </div>
  );
}