package ecrf.user.dynamic.include.tophead;

import com.liferay.portal.kernel.servlet.taglib.BaseDynamicInclude;
import com.liferay.portal.kernel.servlet.taglib.DynamicInclude;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.osgi.service.component.annotations.Component;

@Component(
		immediate = true,
		service = DynamicInclude.class
	)
public class ECRFUserTopHeadDynamicInclude extends BaseDynamicInclude {

	@Override
	public void include(HttpServletRequest request, HttpServletResponse response, String key)
			throws IOException {
		PrintWriter printWriter = response.getWriter();
		
		String content = "<link rel=\"stylesheet\" type = \"text/css\" href=\"/o/ecrf.user.dynamic.include/css/ecrf-user.css\" >";
		
		printWriter.println(content);
	}

	@Override
	public void register(DynamicIncludeRegistry dynamicIncludeRegistry) {
		dynamicIncludeRegistry.register(  "/html/common/themes/top_head.jsp#post" );
	}

}