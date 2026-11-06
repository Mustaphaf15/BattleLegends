extends SceneTree

func _initialize() -> void:
    var settings := EditorInterface.get_editor_settings()
    var sdk := OS.get_environment("ANDROID_HOME")
    var java := OS.get_environment("JAVA_HOME")
    settings.set_setting("export/android/android_sdk_path", sdk)
    settings.set_setting("export/android/java_sdk_path", java)
    settings.save()
    print("Configured Android SDK: ", sdk, " Java: ", java)
    quit()
