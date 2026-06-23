local M = {}

local function path_of(file)
	local path = tostring(file.url.path or file.url)
	return path:gsub("^file://", "")
end

local function run(cmd, args)
	local output = Command(cmd):arg(args):output()
	if not output or not output.status.success then
		return nil
	end

	return output.stdout:gsub("\r\n", "\n"):gsub("%s+$", "")
end

local function exif(path)
	return run("exiftool", {
		"-FileType",
		"-MIMEType",
		"-FileSize",
		"-ImageSize",
		"-Megapixels",
		"-ColorSpace",
		"-BitDepth",
		"-Compression",
		"-PhotometricInterpretation",
		"-Make",
		"-Model",
		"-LensModel",
		"-FNumber",
		"-ExposureTime",
		"-ISO",
		"-CreateDate",
		"-ModifyDate",
		"-Duration",
		"-VideoFrameRate",
		"-AudioFormat",
		"-AudioChannels",
		"-PageCount",
		path,
	})
end

local function media(path)
	return run("mediainfo", { path })
end

local function file_info(path)
	return run("file", { "-b", path })
end

local function metadata(job)
	local path = path_of(job.file)
	local mime = job.mime or ""
	local text

	if mime:match("^image/") or mime == "application/pdf" then
		text = exif(path)
	elseif mime:match("^audio/") or mime:match("^video/") then
		text = media(path)
	end

	return text or file_info(path) or "No metadata available"
end

local function rows_from(text)
	local rows = { ui.Row({ "Metadata" }):style(ui.Style():fg("green")) }

	for line in text:gmatch("[^\n]+") do
		local key, value = line:match("^%s*([^:]-)%s*:%s*(.+)$")
		if key and value then
			rows[#rows + 1] = ui.Row { " " .. key .. ":", value }
		else
			rows[#rows + 1] = ui.Row { " ", line }
		end
	end

	return rows
end

function M:peek(job)
	ya.preview_widget(job, ui.Text(metadata(job)):area(job.area))
end

function M:seek() end

function M:spot(job)
	ya.spot_table(
		job,
		ui.Table(rows_from(metadata(job)))
			:area(ui.Pos { "center", w = 80, h = 24 })
			:row(job.skip)
			:row(1)
			:col(1)
			:col_style(th.spot.tbl_col)
			:cell_style(th.spot.tbl_cell)
			:widths { ui.Constraint.Length(24), ui.Constraint.Fill(1) }
	)
end

return M
