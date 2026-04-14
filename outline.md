Review the documentation for the `super_annotations` - https://pub.dev/packages/super_annotations - dart package.

Review the documentation for the `melos` - https://pub.dev/packages/melos - dart package.  Along with the `melos` documentation site - https://melos.invertase.dev/~melos-latest

Review this article about annotations and code generation - https://medium.com/@michael_dark/annotation-based-code-generation-in-dart-694b9fba2fa9

Review the documentation associated with speckit, which has skills and commands that will be used in the development of this project - https://github.com/github/spec-kit, also look at https://docs.runmaestro.ai/speckit-commands which summarizes when a given command should be used.

Review this site - https://modelcontextprotocol.io/specification/2025-11-25 - and follow relevant links (especially protocol and json schema related) to get an understanding of mcp and its json schema.

This project has two main goals.

1. Create a dart language packages that can be used to annotate existing methods in a dart library, allowing the functionality of the library to be exposed as an mcp server.
2. Create a dart language packages that can be used with `build_runner` to generate the dart code based on the annotations.  The generated code should if possible include a means to make the mcp server available through http (steamable or otherwise) or provide an alternate suggestion that would allow for stdio communication.

Here is a sample of how the anottations might work.  No `transprt` assumes all available.

```dart
  @mcp(transport: 'stdio')

  @tool()
  /// This operation creates new device users and corresponding credentials on a
  /// device for authentication purposes. The device shall support creation of
  /// device users and their credentials through the CreateUsers command. Either
  /// all users are created successfully or a fault message shall be returned
  /// without creating any user.
  ///
  /// ONVIF compliant devices are recommended to support password length of at
  /// least 28 bytes, as clients may follow the password derivation mechanism
  /// which results in 'password equivalent' of length 28 bytes, as described in
  /// section 3.1.2 of the ONVIF security white paper.
  ///
  /// Access Class: WRITE_SYSTEM
  Future<bool> createUsers(List<User> users) async {
    loggy.debug('createUsers');

    final responseEnvelope = await transport.securedRequest(
      uri,
      soap.Body(request: DeviceManagementRequest.createUsers(users)),
    );

    if (responseEnvelope.body.hasFault) {
      throw Exception(responseEnvelope.body.fault.toString());
    }

    return true;
  }
```

The generator will create a tool using the name of the annotated method and a description from the provided comments, the `tool` annotation should also have a `description` attribute to override the comments, or to use if no comments are provided.  Other aspects of the tool schema that cannot be derived from the source code will be supplied as attributes of the annotation, like "icons" and "execution"

I would like you to build a plan for the development of the described pacakges.  The project should be structured as a dart monorepo using `melos`.  The plan should include a list of /speckit.specify commands that describe each of the features that should be implemented for the project.
