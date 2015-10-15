package stripes.smscrew.push;

import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.SimpleMessage;
import net.sourceforge.stripes.validation.SimpleError;
import net.sourceforge.stripes.validation.Validate;
import net.sourceforge.stripes.validation.ValidationError;
import net.sourceforge.stripes.validation.ValidationErrors;

import com.telkomsel.itvas.garudasmscrew.PushEntry;
import com.telkomsel.itvas.garudasmscrew.PushType;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class FreeMessageActionBean extends WebStarterActionBean {
    @Validate(required=true)
    private String idCrew;
    
    @Validate(required=true)
    private String message;
    
    public Resolution action() {
    	PushEntry push = new PushEntry();
    	push.setIdCrew(idCrew);
    	push.setMessage(message);
    	push.setType(PushType.FREE_MESSAGE);
    	if (!push.create()) {
    		getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menambahkan data, hubungi administrator"));
    	} else {
    		getContext().getMessages().add(
					new SimpleMessage("Berhasil menambahkan data")
				);
    	}
    	
    	return new ForwardResolution("/push/FreeMessage.jsp");
    }


	public String getIdCrew() {
		return idCrew;
	}


	public void setIdCrew(String idCrew) {
		this.idCrew = idCrew;
	}


	public String getMessage() {
		return message;
	}


	public void setMessage(String message) {
		this.message = message;
	}
}
